#############################################################################################
#############################################################################################
##
## PROJECT-DEFINITIONS
##
#############################################################################################
#############################################################################################

COPYRIGHT_TEXT  := © schukai GmbH, Released under the AGPL 3.0 License.

#############################################################################################
#############################################################################################
##
## more general block with standard definitions
##
#############################################################################################
#############################################################################################

# get Makefile directory name: http://stackoverflow.com/a/5982798/376773
THIS_MAKEFILE_PATH:=$(word $(words $(MAKEFILE_LIST)),$(MAKEFILE_LIST))
THIS_DIR:=$(shell cd $(dir $(THIS_MAKEFILE_PATH));pwd)/
THIS_MAKEFILE:=$(THIS_DIR)$(THIS_MAKEFILE_PATH)

# colors
BLACK        := $(shell tput -Txterm setaf 0)
RED          := $(shell tput -Txterm setaf 1)
GREEN        := $(shell tput -Txterm setaf 2)
YELLOW       := $(shell tput -Txterm setaf 3)
LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
PURPLE       := $(shell tput -Txterm setaf 5)
BLUE         := $(shell tput -Txterm setaf 6)
WHITE        := $(shell tput -Txterm setaf 7)
RESET        := $(shell tput -Txterm sgr0)

INFO    := $(GREEN)
COMMENT := $(YELLOW)

# Output control and standard outputs
MARKER           := $(BLUE)[+]$(RESET)
ERRORMARKER      := $(RED)[-]$(RESET)
## Deactivate the QUIET mode by overwriting the value with space

ifndef DEBUG
    QUIET = @
else
    QUIET = 
endif

ifndef DONTOPENBROWSER
    OPENBROWSER = true
else
    OPENBROWSER = false
endif

ECHO             := @echo
ECHOMARKER       := @echo "$(MARKER) $0"
ECHOERRORMARKER  := @echo "$(ERRORMARKER) $0"

# Use bash instead of sh
## Sets the shell used
SHELL            =  bash

# path and binaries
AWK              := awk
CP               := cp
CD               := cd
KILL             := /bin/kill
M4               := m4
MV               := mv
RM               := rm -f
MKDIR            := mkdir -p
SED              := sed
FIND             := find
SORT             := sort
TOUCH            := touch
WGET             := wget
CHMOD            := chmod
RSYNC            := rsync
DOCKER           := docker
NPX              := npx
AWS              := aws
XARGS            := xargs
GREP             := grep
NPM              := npm
make             := make
GIT              := git
NPX              := npx
NODE             := node
CAT              := cat
ECHO             := echo

# Executable Programs the Installed be have to
EXECUTABLES = $(AWK) $(CP) $(KILL) $(M4) $(MV) rm mkdir $(SED) $(SORT) $(TOUCH) $(WGET) $(CHMOD) $(NPX) $(FIND) $(XARGS) $(GREP) $(NPM) $(GIT) $(NPX) $(ECHO) $(CAT); 
K := $(foreach exec,$(EXECUTABLES),\
        $(if $(shell which $(exec)),some string,$(error "Missing $(exec) in PATH; please install")))

#############################################################################################
#############################################################################################
##
## DEFAULT-TARGETS
##
#############################################################################################
#############################################################################################

# @see .PHONY https://www.gnu.org/software/make/manual/html_node/Phony-Targets.html#Phony-Targets

.DEFAULT_GOAL := help

.PHONY: print
print:
	$(ECHO) "THIS_MAKEFILE:      $(THIS_MAKEFILE)"
	$(ECHO) "THIS_MAKEFILE_PATH: $(THIS_MAKEFILE_PATH)"
	$(ECHO) "THIS_DIR:           $(THIS_DIR)"

# Add a comment to the public targets so that it appears
# in this help Use two # characters for a help comment
.PHONY: help
help:
	@printf "${COMMENT}Usage:${RESET}\n"
	@printf " make [target] [arg=\"val\"...]\n\n"
	@printf "${COMMENT}Available targets:${RESET}\n"
	@awk '/^[a-zA-Z\-_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${INFO}%-22s${RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n${COMMENT}Available arguments:${RESET}\n"
	@printf "\n ${INFO}DONTOPENBROWSER${RESET}        disable open chrome"
	@printf "\n ${INFO}NEXTVERSION${RESET}            see target release => 0 – major, 1 – minor (default), 2 – patch\n"
	@awk '/^(([a-zA-Z\-_0-9\.@]+)\s=)/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${INFO}%-22s${RESET} %s (Default: %s)\n", $$1, helpMessage, $$3; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)
	@printf "\n"

.PHONY: variables
## Print all Variables
variables:
	@$(foreach v, $(.VARIABLES), $(if $(filter file,$(origin $(v))), $(info $(INFO)$(v)$(RESET)=$($(v))$(RESET))))

#############################################################################################
#############################################################################################
##
## DIRECTORIES
##
#############################################################################################
#############################################################################################

SCRIPT_PATH          :=   $(THIS_DIR)scripts/


PACKAGE_DIR                                := $(THIS_DIR)
PACKAGE_DIST_DIR                           := $(THIS_DIR)dist/
PACKAGE_DIST_FILE                          := $(PACKAGE_DIST_DIR)grapesjs-blocks-bootstrap5.min.js
PACKAGE_SOURCE_DIR                         := $(THIS_DIR)source/
PACKAGE_SOURCE_FILES                       := $(shell find $(PACKAGE_SOURCE_DIR) -name '*.js')
PACKAGE_RELATIVE_SOURCE_FILES              := $(shell find $(PACKAGE_SOURCE_DIR) -name '*.js' -exec realpath --relative-to $(THIS_DIR) {} \;   )
PACKAGE_VERSION                            := $(shell jq -r ".version" $(PACKAGE_DIR)package.json)

#############################################################################################
#############################################################################################
##
## GIT-TARGETS
##
#############################################################################################
#############################################################################################


## Git Commit Message for git-push
MESSAGE := current status

.PHONY: git-branch
## create new branch (use TAG-Variable)
git-branch:

ifeq (, $(shell command -v uuidgen))
	$(error "No uuidgen in PATH, consider doing apt-get install uuidgen")
endif

	$(QUIET) export BRANCH="$(shell uuidgen --random)" ; \
	$(GIT) checkout -b $${BRANCH} && \
	RESULT=$$($(GIT) push origin $$BRANCH 2>&1) && \
    RESULT2=$$($(GIT) branch --set-upstream-to=origin/$$BRANCH $$BRANCH) && \
	GITLABURL=$$(echo "$$RESULT" | tr '\n' '\#' | grep -o 'remote\:\s*https:\/\/gitlab\.schukai\.com[^ ]*' | cut -d " " -f2-9 | sed -e 's/^[ \t]*//') && \
	if $(OPENBROWSER) ; then google-chrome --profile-directory="Default" $$GITLABURL ; fi


.PHONY: git-to-master
## git checkout master, fetch and merge
git-to-master:
	$(GIT) checkout master && $(GIT) fetch -pP && $(GIT) merge


.PHONY: git-push-to-server
## git push changes to server
git-push-to-server:
	$(GIT) add -A
	$(GIT) commit -m"$(MESSAGE)"
	$(GIT) push

.PHONY: git-push
## git create branch and push changes to server
git-push: git-branch git-push-to-server

.PHONY: git-tag
## git create version tag
git-tag:
	$(GIT) tag -a "$(PACKAGE_VERSION)" -m "release $(PACKAGE_VERSION)"

#############################################################################################
#############################################################################################
##
## NODE-DEFINITIONS
##
#############################################################################################
#############################################################################################

NODE_MODULES_DIR := $(THIS_DIR)node_modules/
NODE_MODULES_BIN_DIR := $(NODE_MODULES_DIR).bin/

WEBPACK       := $(NODE_MODULES_BIN_DIR)webpack
BABEL         := $(NODE_MODULES_BIN_DIR)babel
UGLIFYJS      := $(NODE_MODULES_BIN_DIR)uglifyjs

$(NODE_MODULES_DIR): $(THIS_DIR)package.json
	$(QUIET) $(NPM) install 
	$(QUIET) $(RM) node_modules/.modified
	$(QUIET) $(TOUCH) -m node_modules/.modified	

#############################################################################################
#############################################################################################
##
## DEFAULT-DEFINITIONS
##
#############################################################################################
#############################################################################################


.PHONY: clean
## clean 
clean:
	$(QUIET) $(RM) --recursive $(THIS_DIR)dist/

$(PACKAGE_DIST_FILE): $(PACKAGE_SOURCE_FILES)
	$(QUIET) $(NPM) run build

.PHONY: build
## create all packages
build: $(NODE_MODULES_DIR) $(PACKAGE_DIST_FILE)

.PHONY: dev
## start dev server
dev: $(NODE_MODULES_DIR)
	$(QUIET) $(NPM) run start

FILEMARKER:=\#GITIGNORE-START

$(PACKAGE_DIR).npmignore: $(PACKAGE_DIR).gitignore
	$(QUIET) $(SED) -i -n '/$(FILEMARKER)/q;p'  $(PACKAGE_DIR).npmignore  
	$(QUIET) $(ECHO) "$(FILEMARKER)" >> $(PACKAGE_DIR).npmignore  
	$(QUIET) $(ECHO) "" >> $(PACKAGE_DIR).npmignore  
	$(QUIET) $(ECHO) "" >> $(PACKAGE_DIR).npmignore  
	$(QUIET) $(CAT) $(PACKAGE_DIR).gitignore >> $(PACKAGE_DIR).npmignore  

.PHONY: release
## release repos with new version (use NEXTVERSION)
release:
	$(ECHOMARKER) "release"
	$(QUIET) $(SCRIPT_PATH)increase-version.sh "$(PACKAGE_DIR)package.json" "$(PACKAGE_VERSION)" "$(NEXTVERSION)"  
	$(QUIET) $(MAKE) clean
	$(QUIET) $(MAKE) build
	$(QUIET) $(MAKE) npm-publish
	$(QUIET) touch $(THIS_DIR)package.json

.PHONY: npm-publish
## publish library to npm
npm-publish: build $(PACKAGE_DIR).npmignore
	$(ECHOMARKER) "publish"
	$(QUIET) $(CD) $(THIS_DIR) ; \
		$(NPM) publish --access public ; \
		$(CD) -




