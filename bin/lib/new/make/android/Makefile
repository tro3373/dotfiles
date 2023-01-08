SERVICE=android
CONTAINER=gradle:7.3.3-jdk11
PKG := com.example.app.dev.debug
.DEFAULT_GOAL := inpect

tag:
	@export tag=v$$(grep "versionName " app/build.gradle |cut -d\" -f2) && git tag "$$tag" && echo "==> $$tag tagged."

zip:
	@zip -r ${SERVICE}.signingConfigs.zip ./app/signingConfigs

log:
	@adb shell run-as $(PKG) cat /data/data/$(PKG)/files/logs/app.log
logs:
	@for d in /data/data/$(PKG)/files/logs{,/archives}; do \
		echo "==> $$d"; \
		adb shell run-as $(PKG) ls -lah $$d; \
	done
log_tailf:
	@adb shell run-as $(PKG) tail -F /data/data/$(PKG)/files/logs/app.log
log_rm:
	@adb shell run-as $(PKG) rm -rfv /data/data/$(PKG)/files/logs/archives

db_file_name := app_db
pull_db:
	@adb shell "run-as $(PKG) chmod 666 /data/data/$(PKG)/databases/$(db_file_name)"
	@adb exec-out run-as $(PKG) cat databases/$(db_file_name) >$(db_file_name)
	@adb exec-out run-as $(PKG) cat databases/$(db_file_name)-shm >$(db_file_name)-shm
	@adb exec-out run-as $(PKG) cat databases/$(db_file_name)-wal >$(db_file_name)-wal
	@adb shell "run-as $(PKG) chmod 600 /data/data/$(PKG)/databases/$(db_file_name)"

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

_gradle:
	@test -n "$${ANDROID_HOME}" || (echo "=> No env ANDROID_HOME is defined." 1>&2 && exit 1)
	@docker run -it --rm \
		--name gradle \
		-e GRADLE_USER_HOME=/src/.gradle_docker \
		-e ANDROID_HOME=/android-sdk \
		-v $${ANDROID_HOME}:/android-sdk \
		-v $(PWD):/src \
		-w /src \
		$(CONTAINER) \
		./gradlew $(TASK)

task_list:
	@TASK=tasks make _gradle


apk:
	@TASK=:app:assembleDevDemoDebug make _gradle
	@make TARGET_DIR=$(PWD)/app/build/outputs/apk/devDemo/debug open_dir

release-aab:
	@TASK=:app:bundleSunwiseFullRelease make _gradle
	@make TARGET_DIR=$(PWD)/app/build/outputs/bundle/sunwiseFullRelease open_dir

inpect:
	@docker inspect $(CONTAINER)

open_dir:
	@command -v open >&/dev/null
	@open $(TARGET_DIR)
