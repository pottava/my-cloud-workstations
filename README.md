# [Cloud Workstations カスタマイズ](https://cloud.google.com/workstations/docs/customize-container-images?hl=ja) スクリプト

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
docker run --name ws --rm --privileged -p 8080:80 test
docker rm -f ws
```

## 4. リポジトリへ保存

```sh
gcloud auth configure-docker ${region}-docker.pkg.dev
docker tag test ${region}-docker.pkg.dev/${project_id}/workstations/customized:latest
docker push ${region}-docker.pkg.dev/${project_id}/workstations/customized:latest
```

または

```sh
gcloud builds submit --region ${region} --tag ${region}-docker.pkg.dev/${project_id}/workstations/customized:latest
```

## 5. Workstation のためのサービスアカウントを作成 (optional)

```sh
gcloud iam service-accounts create sa-workstations --display-name "A service account for Cloud Workstations"
gcloud artifacts repositories add-iam-policy-binding workstations --location ${region} \
    --member serviceAccount:sa-workstations@${project_id}.iam.gserviceaccount.com \
    --role roles/artifactregistry.reader
```

## 参考: GitHub Actions による CI/CD

GitHub に渡すサービスアカウントを生成

```bash
gcloud iam service-accounts create sa-githubq
gcloud projects add-iam-policy-binding "${project_id}" \
    --member "serviceAccount:sa-github@${project_id}.iam.gserviceaccount.com" \
    --role "roles/viewer"
gcloud projects add-iam-policy-binding ${project_id} \
    --member="serviceAccount:sa-github@${project_id}.iam.gserviceaccount.com" \
    --role="roles/storage.admin"
gcloud projects add-iam-policy-binding ${project_id} \
    --member="serviceAccount:sa-github@${project_id}.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.writer"
gcloud projects add-iam-policy-binding ${project_id} \
    --member="serviceAccount:sa-github@${project_id}.iam.gserviceaccount.com" \
    --role="roles/workstations.admin"
gcloud iam service-accounts add-iam-policy-binding \
    sa-workstations@${project_id}.iam.gserviceaccount.com \
    --member "serviceAccount:sa-github@${project_id}.iam.gserviceaccount.com" \
    --role "roles/iam.serviceAccountUser"
```

GitHub に安全に権限を渡すため、[Workload Identity 連携](https://cloud.google.com/iam/docs/workload-identity-federation?hl=ja) を設定

```bash
gcloud iam workload-identity-pools create "idpool-cicd" --location "global" \
    --display-name "Identity pool for CI/CD services"
idp_id=$( gcloud iam workload-identity-pools describe "idpool-cicd" \
    --location "global" --format "value(name)" )
```

GitHub リポジトリを一意に識別するための ID を設定し

```bash
repository_owner=<org-id>
```

Identity Provider (IdP) を作成

```bash
gcloud iam workload-identity-pools providers create-oidc "idp-github-${repository_owner}" \
    --workload-identity-pool "idpool-cicd" --location "global" \
    --issuer-uri "https://token.actions.githubusercontent.com" \
    --attribute-mapping "google.subject=assertion.sub,attribute.repository_owner=assertion.repository_owner" \
    --attribute-condition "assertion.repository_owner=='${repository_owner}'" \
    --display-name "Workload IdP for GitHub"
gcloud iam service-accounts add-iam-policy-binding sa-github@${project_id}.iam.gserviceaccount.com \
    --member "principalSet://iam.googleapis.com/${idp_id}/attribute.repository_owner/${repository_owner}" \
    --role "roles/iam.workloadIdentityUser"
gcloud iam workload-identity-pools providers describe "idp-github-${repository_owner}" \
    --workload-identity-pool "idpool-cicd" --location "global" \
    --format "value(name)"
```

GitHub から Google Cloud 上のリソースにアクセスするための変数をセット

- **GOOGLE_CLOUD_PROJECT**: プロジェクト ID
- **GOOGLE_CLOUD_WORKLOAD_IDP**: 最後に出力された IdP ID
- **CLOUD_WORKSTATIONS_CLUSTER**: Cloud Workstations クラスタ ID
