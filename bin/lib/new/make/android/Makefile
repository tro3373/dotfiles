SHELL := bash
.SHELLFLAGS := -eu -o pipefail -c # -c: Needed in .SHELLFLAGS. Default is -c.
.DEFAULT_GOAL := inpect

dotenv := $(PWD)/.env
-include $(dotenv)

svc := android
container := gradle:7.3.3-jdk11
pkg := com.example.app.dev.debug

export

tag:
	@export tag=v$$(grep "versionName " app/build.gradle |cut -d\" -f2) && git tag "$$tag" && echo "==> $$tag tagged."

zip:
	@zip -r ${svc}.signingConfigs.zip ./app/signingConfigs
unzip:
	@test -e ${svc}.signingConfigs.zip
	@unzip ${svc}.signingConfigs.zip

log:
	@adb shell run-as $(pkg) cat /data/data/$(pkg)/files/logs/app.log
logs:
	@for d in /data/data/$(pkg)/files/logs{,/archives}; do \
		echo "==> $$d"; \
		adb shell run-as $(pkg) ls -lah $$d; \
	done
log_tailf:
	@adb shell run-as $(pkg) tail -F /data/data/$(pkg)/files/logs/app.log
log_rm:
	@adb shell run-as $(pkg) rm -rfv /data/data/$(pkg)/files/logs/archives

db_file_name := app_db
pull_db:
	@adb shell "run-as $(pkg) chmod 666 /data/data/$(pkg)/databases/$(db_file_name)"
	@adb exec-out run-as $(pkg) cat databases/$(db_file_name) >$(db_file_name)
	@adb exec-out run-as $(pkg) cat databases/$(db_file_name)-shm >$(db_file_name)-shm
	@adb exec-out run-as $(pkg) cat databases/$(db_file_name)-wal >$(db_file_name)-wal
	@adb shell "run-as $(pkg) chmod 600 /data/data/$(pkg)/databases/$(db_file_name)"

# For wireless debug
# 1. connect device to pc
# 2. Enable wireless debug in android device
# 3. make tcpip
tcpip:
	@adb tcpip 5555
# 4. Open `wireless debug settings in device developper mode` and copy `IPAddress and Port`
# 5. make connect {Copied IPAddress}:{Copied port}. Connected in wireless, then disconnect wire.
connect:
	@adb connect $(arg)

task_list:
	@TASK=tasks make _gradle
apk:
	@TASK=:app:assembleDevDemoDebug make _gradle
	@make TARGET_DIR=$(PWD)/app/build/outputs/apk/devDemo/debug open_dir
release-aab:
	@TASK=:app:bundleSunwiseFullRelease make _gradle
	@make TARGET_DIR=$(PWD)/app/build/outputs/bundle/sunwiseFullRelease open_dir
_gradle:
	@test -n "$${ANDROID_HOME}" || (echo "=> No env ANDROID_HOME is defined." 1>&2 && exit 1)
	@docker run -it --rm \
		--name gradle \
		-e GRADLE_USER_HOME=/app/.gradle_docker \
		-e ANDROID_HOME=/android-sdk \
		-v $${ANDROID_HOME}:/android-sdk \
		-v $(PWD):/app \
		-w /app \
		$(container) \
		./gradlew $(TASK)


inpect:
	@docker inspect $(container)

open_dir:
	@command -v open >&/dev/null
	@open $(TARGET_DIR)
