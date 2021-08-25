# tf-oci-jupyter-notebook

## Usage
1. Modify variables.tf
2. Launch
```
$ terraform init
$ terraform plan
$ terraform apply
```

## Use as local runtime for Google Colaboratory
1. Connect to a VM
```
$ ssh -i <path to private key> -L 8000:localhost:8888 ubuntu@<IP address>
```
2. Launch Jupyter Notebook
```
$ jupyter notebook
```
3. Connect to a local runtime in Colab
