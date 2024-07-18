#!	/usr/bin/ksh

###############################################################################
#	build a golang project described by a build config file
################################################################################

#	color constants
export	RED='\033[0;31m'
export	GREEN='\033[0;32m'
export	LIGHTGRAY='\033[0;37m'
export	NOCOLOR='\033[0m'

#	set environment
export	PROJECT_CONFIG_FILE='build.cfg'
export	TARGET_DIR='bin'
export	VERBOSE='false'
export	TARGET_LIST=''

#	function to check if the basic required tools are available
function checkBasicRequiredTools {

	local	TMP_OUTPUT=''

	#	if go toolchain is available
	if [ -z "${GOROOT}" ]
	then
		echo -e "[build] ${RED}error: GOROOT environment variable must be set${NOCOLOR}"
		exit 1
	fi

	TMP_OUTPUT=$( which go 2> /dev/null )
	if [ $? -ne 0 ]
	then
		echo -e "[build] ${RED}error: golang compiler is required to run this script${NOCOLOR}"
		exit 1
	fi

	#	 if jq is available
	TMP_OUTPUT=$( which jq 2> /dev/null )
	if [ $? -ne 0 ]
	then
		echo -e "[build] ${RED}error: 'jq' utility is required to run this script${NOCOLOR}"
		exit 1
	fi
}

#	function to check if the additional required tools are available
function checkAdditionalRequiredTools {

	local	TMP_OUTPUT=''

	#	based on the configuration check for availability of any additionl tool
	for TOOL in ${PROJECT_ADDITIONAL_TOOLS}
	do
		TMP_OUTPUT=$( which ${TOOL} 2> /dev/null )
		if [ $? -ne 0 ]
		then
			echo -e "[build] ${RED}error: '${TOOL}' utility is required to run this script${NOCOLOR}"
			exit 1
		fi
	done
}

#	function to load project configuration from config file
function loadProjectConfig {

	local	PROJECT_CONFIG="$( cat ${PROJECT_CONFIG_FILE} )"
	local	NUM_SOURCE_FILES=$( echo ${PROJECT_CONFIG} | jq '.source | length' )
	local	NUM_PACKAGES=$( echo ${PROJECT_CONFIG} | jq '.packages | length' )
	local	NUM_DEPENDENCIES=$( echo ${PROJECT_CONFIG} | jq '.dependencies | length' )

	export	PROJECT_NAME="$( echo ${PROJECT_CONFIG} | jq '.project' | tr -d '"' )"
	export	PROJECT_DESCRIPTION="$( echo ${PROJECT_CONFIG} | jq '.description' | tr -d '"' )"
	export	PROJECT_SOURCE_DIR="$( echo ${PROJECT_CONFIG} | jq '.source_directory' | tr -d '"' )"

	if [ ${NUM_SOURCE_FILES} -eq 0 ]
	then
		export	PROJECT_SOURCE=''
	else
		export	PROJECT_SOURCE="$( echo ${PROJECT_CONFIG} | jq '.source | .[]' | tr -d '"' )"
	fi

	if [ ${NUM_PACKAGES} -eq 0 ]
	then
		export	PROJECT_PACKAGES=''
	else
		export	PROJECT_PACKAGES="$( echo ${PROJECT_CONFIG} | jq '.packages | .[]' | tr -d '"' )"
	fi

	export	PROJECT_TARGET="$( echo ${PROJECT_CONFIG} | jq '.target' | tr -d '"' )"

	if [ ${NUM_DEPENDENCIES} -eq 0 ]
	then
		export	PROJECT_DEPENDENCIES=''
	else
		export	PROJECT_DEPENDENCIES="$( echo ${PROJECT_CONFIG} | jq '.dependencies | .[]' | tr -d '"' )"
	fi

	export	PROJECT_BUILD_FLAGS="$( echo ${PROJECT_CONFIG} | jq '.build_flags' | tr -d '"' )"
	export	PROJECT_TEST_FLAGS="$( echo ${PROJECT_CONFIG} | jq '.test_flags' | tr -d '"' )"
	export	PROJECT_TEST_DIR="$( echo ${PROJECT_CONFIG} | jq '.test_directory' | tr -d '"' )"
	export	PROJECT_DOCKER_FILE="$( echo ${PROJECT_CONFIG} | jq '.docker_file' | tr -d '"' )"
	export	PROJECT_DOCKER_COMPOSE_FILE="$( echo ${PROJECT_CONFIG} | jq '.docker_compose_file' | tr -d '"' )"
	export	PROJECT_ADDITIONAL_TOOLS=''

	#	TODO: change the config file to allow specify the version of dependency packages
	#	TODO: change the config file to allow specify an environment file

	#	check all required parameters
	if [ -z "${PROJECT_NAME}" -o "${PROJECT_NAME}" == 'null' ]
	then
		echo -e "[build] ${RED}error: required field \"project\" missing or empty on configuration file: ${PROJECT_CONFIG_FILE}${NOCOLOR}"
		exit 1
	fi

	if [ -z "${PROJECT_DESCRIPTION}" -o "${PROJECT_DESCRIPTION}" == 'null' ]
	then
		echo -e "[build] ${RED}error: required field \"description\" missing or empty on configuration file: ${PROJECT_CONFIG_FILE}${NOCOLOR}"
		exit 1
	fi

	#	set default values for missing parameters
	if [ -z "${PROJECT_SOURCE_DIR}" -o "${PROJECT_SOURCE_DIR}" == 'null' ]
	then
		PROJECT_SOURCE_DIR='.'
	fi

	if [ -z "${PROJECT_SOURCE}" -o "${PROJECT_SOURCE}" == 'null' ]
	then
		PROJECT_SOURCE="$( ls ${PROJECT_SOURCE_DIR}/*.go )"
		echo -e "[debug] ${LIGHTGRAY}project source files: ${PROJECT_SOURCE}${NOCOLOR}"
	fi

	if [ -z "${PROJECT_TARGET}" -o "${PROJECT_TARGET}" == 'null' ]
	then
		PROJECT_TARGET="${PROJECT_NAME}"
	fi

	if [ -z "${PROJECT_TEST_DIR}" -o "${PROJECT_TEST_DIR}" == 'null' ]
	then
		PROJECT_TEST_DIR='.'
	fi

	if [ -z "${PROJECT_DOCKER_FILE}" -o "${PROJECT_DOCKER_FILE}" == 'null' ]
	then
		PROJECT_DOCKER_FILE=''
	fi

	#	validate source directory
	if [ ! -d "${PROJECT_SOURCE_DIR}" ]
	then
		echo -e "[build] ${RED}error: invalid source directory: ${PROJECT_SOURCE_DIR}${NOCOLOR}"
		exit 1
	fi

	#	validate test directory
	if [ ! -d "${PROJECT_TEST_DIR}" ]
	then
		echo -e "[build] ${RED}error: invalid test directory: ${PROJECT_TEST_DIR}${NOCOLOR}"
		exit 1
	fi

	#	validate test directory
	if [ ! -z "${PROJECT_DOCKER_FILE}" -a ! -f "${PROJECT_DOCKER_FILE}" ]
	then
		echo -e "[build] ${RED}error: Docker file not found: ${PROJECT_DOCKER_FILE}${NOCOLOR}"
		exit 1
	fi

	#	load the integrated tests configuration
	export	PROJECT_INTEGRATION_TESTS=''
	local	NUM_INTEGRATION_TESTS=$( echo ${PROJECT_CONFIG} | jq '.integration_tests | length' )
	local	INDEX=0
	local	TEST_DESCRIPTION=''
	local	TEST_TOOL=''
	local	TEST_ENVIRONMENT=''
	local	TEST_COLLECTION=''
	local	TEST_COMMAND=''
	local	NEWMAN_REQUIRED='false'

	if [ ${NUM_INTEGRATION_TESTS} -gt 0 ]
	then
		for INDEX in {0..$(( ${NUM_INTEGRATION_TESTS} - 1 ))}
		do
			TEST_DESCRIPTION="$( echo ${PROJECT_CONFIG} | jq ".integration_tests | .[${INDEX}].description" | tr -d '"' )"
			TEST_TOOL="$( echo ${PROJECT_CONFIG} | jq ".integration_tests | .[${INDEX}].tool" | tr -d '"' )"

			case ${TEST_TOOL} in

				#	format newman execution command
				newman )
				NEWMAN_REQUIRED='true'

				TEST_ENVIRONMENT="$( echo ${PROJECT_CONFIG} | jq ".integration_tests | .[${INDEX}].environment" | tr -d '"' )"
				TEST_COLLECTION="$( echo ${PROJECT_CONFIG} | jq ".integration_tests | .[${INDEX}].collection" | tr -d '"' )"

				TEST_COMMAND="newman run '${PROJECT_TEST_DIR}/${TEST_COLLECTION}' --environment '${PROJECT_TEST_DIR}/${TEST_ENVIRONMENT}'"
				;;

				#	if it's not known or supported test tool
				* )
				echo -e "[build] ${RED}error: unknown/unsupported test tool: ${TEST_TOOL}${NOCOLOR}"
				exit 1
				;;
			esac

			if [ -z "${PROJECT_INTEGRATION_TESTS}" ]
			then
				PROJECT_INTEGRATION_TESTS="${TEST_DESCRIPTION}:${TEST_COMMAND}"
			else
				PROJECT_INTEGRATION_TESTS="${PROJECT_INTEGRATION_TESTS}\n${TEST_DESCRIPTION}:${TEST_COMMAND}"
			fi
		done
	fi

	#	set the list of additional tools
	if [ ${NEWMAN_REQUIRED} == 'true' ]
	then
		PROJECT_ADDITIONAL_TOOLS='newman'
	fi

	if [ ! -z ${PROJECT_DOCKER_FILE} ]
	then
		PROJECT_ADDITIONAL_TOOLS="${PROJECT_ADDITIONAL_TOOLS} docker"
	fi

	if [ ! -z ${PROJECT_DOCKER_COMPOSE_FILE} ]
	then
		PROJECT_ADDITIONAL_TOOLS="${PROJECT_ADDITIONAL_TOOLS} docker-compose"
	fi
}

#	function to execute the "clean" target action
function cleanTarget {

	echo -e "[build] ${TARGET}: ${GREEN}removing required packages and the target file${NOCOLOR}"

	#	TODO: check if it's possible to remove a package installed in GOPATH dir
	#rm -rf pkg/*

	#	remove all go module files
	rm -rf "${PROJECT_SOURCE_DIR}/go.mod" "${PROJECT_SOURCE_DIR}/go.sum"

	for PACKAGE in ${PROJECT_PACKAGES}
	do
		rm -rf "${PROJECT_SOURCE_DIR}/${PACKAGE}/go.mod" "${PROJECT_SOURCE_DIR}/${PACKAGE}/go.sum"
	done

	#	remove project target
	rm -f "${TARGET_DIR}/${PROJECT_TARGET}"
}

#	function to execute the "dependencies" target action
function dependenciesTarget {

	local	BUILD_DIR="$( pwd )"

	echo -e "[build] ${TARGET}: ${GREEN}downloading and installing all dependencies${NOCOLOR}"

	#	generate main packge go module files
	cd "${PROJECT_SOURCE_DIR}"
	go mod init ${PROJECT_NAME}

	for MODULE in ${PROJECT_DEPENDENCIES}
	do
		go get -u ${MODULE}
	done

	for PACKAGE in ${PROJECT_PACKAGES}
	do
		echo "require ${PROJECT_NAME}/${PACKAGE} v0.0.0-unpublished" >> go.mod
		echo "replace ${PROJECT_NAME}/${PACKAGE} v0.0.0-unpublished => ./${PACKAGE}" >> go.mod
		#	TODO: check if this works !
		#echo go mod edit -replace ${PROJECT_NAME}/${PACKAGE}=../src/${PACKAGE}
	done

	cd "${BUILD_DIR}"

	#	create project packages module files
	for PACKAGE in ${PROJECT_PACKAGES}
	do
		cd "${PROJECT_SOURCE_DIR}/${PACKAGE}"
		go mod init ${PROJECT_NAME}/${PACKAGE}
		cd "${BUILD_DIR}"
	done
}

#	function to execute the "compile" target action
function compileTarget {

	local	BUILD_DIR="$( pwd )"

	echo -e "[build] ${TARGET}: ${GREEN}compiling and linking source code${NOCOLOR}"

	rm -f "${TARGET_DIR}/${PROJECT_TARGET}"

	#	TODO: test if it works when the source dir is different than "."
	cd "${PROJECT_SOURCE_DIR}"
	go build ${PROJECT_BUILD_FLAGS} -o "${BUILD_DIR}/${TARGET_DIR}/${PROJECT_TARGET}" ${PROJECT_SOURCE}
	cd "${BUILD_DIR}"
}

#	function to execute the "test" target action
function testTarget {

	local	BUILD_DIR="$( pwd )"
	local	GOTEST_FLAGS="${PROJECT_TEST_FLAGS}"
	local	GOTEST_PACKAGES='.'

	echo -e "[build] ${TARGET}: ${GREEN}running unit tests${NOCOLOR}"

	if [ "${VERBOSE}" == 'true' ]
	then
		GOTEST_FLAGS='-v'
	fi

	#	create a list of all packages to run tests
	for PACKAGE in ${PROJECT_PACKAGES}
	do
		GOTEST_PACKAGES="${GOTEST_PACKAGES} ${PROJECT_NAME}/${PACKAGE}"
	done

	cd "${PROJECT_SOURCE_DIR}"
	go test "${GOTEST_FLAGS}" ${GOTEST_PACKAGES}
	cd "${BUILD_DIR}"

	if [ $? -ne 0 ]
	then
		echo -e "[build] ${RED}error: unit tests failed${NOCOLOR}"
		exit 1
	fi
}

#	function to execute the "package" target action
function packageTarget {

	local	DOCKER_FLAGS=''

	echo -e "[build] ${TARGET}: ${GREEN}package the target in a Docker image${NOCOLOR}"

	if [ ! -z "${PROJECT_DOCKER_FILE}" ]
	then
		if [ "${VERBOSE}" == 'false' ]
		then
			DOCKER_FLAGS='--quiet'
		fi

		docker build --tag  $( echo ${PROJECT_TARGET} | tr [:upper:] [:lower:] ) --file ${PROJECT_DOCKER_FILE} ${DOCKER_FLAGS} .
	fi
}

#	function to execute the "verify" target action
function verifyTarget {

	local	PID=''
	local	ERROR='false'
	local	ORIGINAL_IFS="${IFS}"
	local	TEST_DESCRIPTION=''
	local	TEST_COMMAND=''

	echo -e "[build] ${TARGET}: ${GREEN}execute integration tests${NOCOLOR}"

	#	check that there are at least one test
	if [ -z "${PROJECT_INTEGRATION_TESTS}" ]
	then
		echo -e "[build] ${LIGHTGRAY}nothing to do for \"verify\" target${NOCOLOR}"
	fi

	#	execute the project
	if [ ! -f "${TARGET_DIR}/${PROJECT_TARGET}" ]
	then
		echo -e "[build] ${RED}error: project target file not found: use target \"compile\" to build it before target \"verify\"${NOCOLOR}"
		exit 1
	fi

	#	precedence for execute the application: Docker-composse, Docker or the binary file
	if [ ! -z "${PROJECT_DOCKER_COMPOSE_FILE}" ]
	then
		local	DOCKER_COMPOSE_FLAGS='--detach --force-recreate'

		if [ "${VERBOSE}" == 'false' ]
		then
			docker-compose --file "${PROJECT_DOCKER_COMPOSE_FILE}" up ${DOCKER_COMPOSE_FLAGS}
		else
			docker-compose --file "${PROJECT_DOCKER_COMPOSE_FILE}" --verbose up ${DOCKER_COMPOSE_FLAGS}
		fi
	else
		if [ ! -z "${PROJECT_DOCKER_FILE}" ]
		then
			#	TODO: add the execution using docker
			echo
		else
			${TARGET_DIR}/${PROJECT_TARGET} 1> /dev/null 2> /dev/null &
			if [ $? -ne 0 ]
			then
				echo -e "[build] ${RED}error: cannot run the project target file: ${TARGET_DIR}/${PROJECT_TARGET}${NOCOLOR}"
				exit 1
			fi
			PID=$!
		fi
	fi

	#	execute every integration test
	IFS="$( echo -e "\n" )"

	for INTEGRATION_TEST in ${PROJECT_INTEGRATION_TESTS}
	do
		TEST_DESCRIPTION="$( echo ${INTEGRATION_TEST} | cut -f1 -d':' )"
		TEST_COMMAND="$( echo ${INTEGRATION_TEST} | cut -f2 -d':' )"

		echo -e "[build] ${TARGET}: ${LIGHTGRAY}${TEST_DESCRIPTION}${NOCOLOR}"

		if [ "${VERBOSE}" == 'false' ]
		then
			eval "${TEST_COMMAND}" 1> /dev/null
		else
			eval "${TEST_COMMAND}"
		fi

		if [ $? -ne 0 ]
		then
			echo -e "[build] ${RED}error: integration tests failed${NOCOLOR}"
			ERROR='true'
		fi
	done

	IFS="${ORIGINAL_IFS}"

	#	stop the execution of the application
	if [ ! -z "${PROJECT_DOCKER_COMPOSE_FILE}" ]
	then
		local	DOCKER_COMPOSE_FLAGS='--remove-orphans'

		docker-compose --file "${PROJECT_DOCKER_COMPOSE_FILE}" down ${DOCKER_COMPOSE_FLAGS}
	else
		if [ ! -z "${PROJECT_DOCKER_FILE}" ]
		then
			#	TODO: add the execution using docker
			echo
		else
			kill -9 ${PID}
		fi
	fi

	if [ ${ERROR} == "true" ]
	then
		exit 1
	fi
}

#	function to execute the "run" target action
function runTarget {

	#	execute the project
	if [ ! -f "${TARGET_DIR}/${PROJECT_TARGET}" ]
	then
		echo -e "[build] ${RED}error: project target file not found: use target \"compile\" to build it before target \"verify\"${NOCOLOR}"
		exit 1
	fi

	#	precedence for execute the application: Docker-composse, Docker or the binary file
	if [ ! -z "${PROJECT_DOCKER_COMPOSE_FILE}" ]
	then
		local	DOCKER_COMPOSE_FLAGS='--force-recreate '

		if [ "${VERBOSE}" == 'false' ]
		then
			docker-compose --file "${PROJECT_DOCKER_COMPOSE_FILE}" up ${DOCKER_COMPOSE_FLAGS}
		else
			docker-compose --file "${PROJECT_DOCKER_COMPOSE_FILE}" --verbose up ${DOCKER_COMPOSE_FLAGS}
		fi
	else
		if [ ! -z "${PROJECT_DOCKER_FILE}" ]
		then
			#	TODO: add the execution using docker
			echo
		else
			${TARGET_DIR}/${PROJECT_TARGET}
			if [ $? -ne 0 ]
			then
				echo -e "[build] ${RED}error: cannot run the project target file: ${TARGET_DIR}/${PROJECT_TARGET}${NOCOLOR}"
				exit 1
			fi
		fi
	fi
}

#	CLI arguments parsing

while [ true ]
do
	ARG=${1}

	if [ -z "${ARG}" ]
	then
		break
	fi

	case ${ARG} in

		#	help message option
		--help )
		cat <<HELP_MESSAGE
$( basename ${0} ): [options] targets
options:
	--config-file file-name: set the project config file name (default: ${PROJECT_CONFIG_FILE})
	--target-dir: set the target directory name (default: ${TARGET_DIR})
	--verbose: show detailed information during execution
	--help: show this help message

targets:
	all: the same as the specifying targets "dependencies compile test package verify"
	clean: remove all required packages and the target file
	dependencies: install all dependencies
	compile: compile and link source code
	test: execute unit tests
	package: package the target in a container
	verify: execute integration tests
	run: run the target
HELP_MESSAGE

		exit 0
		;;

		#	config file name option
		--config-file )
		PROJECT_CONFIG_FILE=${2}
		shift
		;;

		#	target directory name option
		--target-dir )
		TARGET_DIR=${2}
		shift
		;;

		#	verbose option
		--verbose )
		VERBOSE='true'
		;;

		#	if it's not an option, it's a target
		* )
		if [ -z "${TARGET_LIST}" ]
		then
			TARGET_LIST="${ARG}"
		else
			TARGET_LIST="${TARGET_LIST} ${ARG}"
		fi
		;;
	esac

	shift
done

#	check if config file exists
if [ -z "${PROJECT_CONFIG_FILE}" -o ! -f ${PROJECT_CONFIG_FILE} ]
then
	echo -e "[build] ${RED}error: build configration file not found: \"${PROJECT_CONFIG_FILE}\"${NOCOLOR}"
	exit 1
fi

#	if necessary, create target directory
if [ ! -d "${TARGET_DIR}" ]
then
	mkdir "${TARGET_DIR}"
fi

#	if necessary, set default target
if [ -z "${TARGET_LIST}" ]
then
	export	TARGET_LIST='compile'
fi

if [ "${TARGET_LIST}" == 'all' ]
then
	export	TARGET_LIST='dependencies compile test package verify'
fi

#	load project config files and perform every specified target
checkBasicRequiredTools
loadProjectConfig
checkAdditionalRequiredTools

for TARGET in ${TARGET_LIST}
do
	case ${TARGET} in

		#	remove all required packages and the target file
		clean )
		cleanTarget
		;;

		#	install all dependencies
		dependencies )
		dependenciesTarget
		;;

		#	compile and link source code
		compile )
		compileTarget
		;;

		#	execute unit tests
		test )
		testTarget
		;;

		#	package the target in a Docker image
		package )
		packageTarget
		;;

		#	execute integration tests
		verify )
		verifyTarget
		;;

		#	run the target
		run )
		echo -e "[build] ${TARGET}: ${GREEN}running the project${NOCOLOR}"

		runTarget
		;;

		#	unknown target
		* )
		echo -e "[build] ${RED}error: unknown target ${TARGET}${NOCOLOR}"
		exit 1
		;;
	esac
done
