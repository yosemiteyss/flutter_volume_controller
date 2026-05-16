# Development Setup

## For Other Platforms

```bash
fvm install 3.41.9
fvm use 3.41.9
fvm flutter pub get
```

## For OHOS

```bash
fvm fork add hos https://gitcode.com/openharmony-tpc/flutter_flutter.git
fvm install hos/oh-3.41.9-dev
fvm use hos/oh-3.41.9-dev
```

```bash
OH_SDK=/Users/kevin/fvm/versions/hos/oh-3.41.9-dev
export FLUTTER_OHOS_STORAGE_BASE_URL=https://flutter-ohos.obs.cn-south-1.myhuaweicloud.com
fvm flutter precache --ohos --force -v
cd ./example/ohos && ohpm install
cd ../.. && fvm flutter pub get
```
