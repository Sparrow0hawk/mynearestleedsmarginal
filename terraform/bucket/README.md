# Cloud Bucket Terraform Config


## Adding data to bucket

Data should be uploaded to the bucket with the following steps after
provisioning infrastructure.

You will need:

- [gsutil](https://cloud.google.com/storage/docs/gsutil)

```bash
gsutil rsync ../../assets/data $(terraform output -raw storage-bucket)
```
