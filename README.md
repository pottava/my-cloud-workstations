[Cloud Workstations カスタマイズ](https://cloud.google.com/workstations/docs/customize-container-images?hl=ja) スクリプト
===

## 1. 環境を設定

```sh
project_id=$( gcloud config get-value project )
region=asia-northeast1
```

## 2. リポジトリの作成

```sh
gcloud artifacts repositories create workstations --location ${region} --repository-format docker \
    --description "A docker repository for Cloud Workstations"
```

## 3. 環境を試行錯誤する

```sh
docker build -t test .
docker run --rm --privileged -p 8080:80 test
```

## 4. リポジトリへ保存

```sh
gcloud auth configure-docker ${region}-docker.pkg.dev
docker tag test ${region}-docker.pkg.dev/${project_id}/workstations/customized:latest
docker push ${region}-docker.pkg.dev/${project_id}/workstations/customized:latest
```

## 5. Workstation のためのサービスアカウントを作成 (optional)

```sh
gcloud iam service-accounts create sa-workstations --display-name "A service account for Cloud Workstations"
gcloud artifacts repositories add-iam-policy-binding workstations --location ${region} \
    --member serviceAccount:sa-workstations@${project_id}.iam.gserviceaccount.com \
    --role roles/artifactregistry.reader
```
