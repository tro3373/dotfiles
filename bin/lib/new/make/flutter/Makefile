# debug/release ビルド
mode := debug
# バンドルID、パッケージ名を変更(XCodeのConfig,AndroidのproductFlavorsに紐づく)
build_flavor := development
# APIの向き先を変更する
dart_flavor := development
# google_service_info_plist := ./ios/Runner/Firebase/$(build_flavor)/GoogleService-Info.plist

.DEFAULT_GOAL := run

devices:
	@flutter devices
run: run-android
run-linux:
	@flutter run -d linux
	@make _run target=linux
run-chrome:
	@make _run target=web-javascript
run-ios:
	@make _run target=ios
run-android:
	@make _run target=android
_run: #_build_prepare
	@export device_id=$$(flutter devices --machine| jq -r '.[]|select(.targetPlatform |startswith("$(target)"))|.id') && \
		echo "==> Running on $$device_id .." && \
		flutter run -d $$device_id --$(mode) --flavor $(build_flavor) --dart-define=FLAVOR=$(dart_flavor)

pub-get:
	@flutter pub get

pub-upgrade:
	@flutter pub upgrade

packages-upgrade:
	@flutter packages upgrade

freeze:
	@flutter pub run build_runner build --delete-conflicting-outputs

dart-fix:
	@dart fix --apply

clean:
	@flutter clean

.PHONY: build
build-apk:
	# Firebase上で、development用に登録されているパッケージ名は `net.algoage.dry_eye_checker`
	#     => Androidで Staging でPushを打つ場合、`--flavor production` でないとパッケージ名が合わないので飛ばない
	@make _build target=apk
build-ios:
	@make _build target=ios

_build: #_build_prepare
	@flutter build $(target) --$(mode) --flavor $(build_flavor) --dart-define=FLAVOR=$(dart_flavor)

# _build_prepare:
# 	@if [[ $(target) == "ios" ]]; then \
# 		test -e $(google_service_info_plist) && \
# 			cp -v $(google_service_info_plist) ./ios/GoogleService-Info.plist; \
# 	fi

install-apk:
	@adb install -r ./build/app/outputs/flutter-apk/app-production-debug.apk
build-install-apk: build-apk install-apk
logcat:
	@adb logcat
logcat-app:
	@app_id=$$(grep applicationId android/app/build.gradle |head -1 |cut -d\" -f2) && \
		adb logcat | grep $${app_id} --color

