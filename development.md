# INSTRUCCIONES DE CONFIGURACION

1. Clonamos el repositorio
```
git clone https://github.com/vfabrizio95-oss/Consersa---Proyecto-Final.git
```

2. verificamos las ramas
```
git branch
```
3. Creamos la rama develop
```
git checkout -b develop
```
3. verificamos que estemos en la rama develop
```
git branch
```
4. Si seguimos en main, cambiamos de rama a develop
```
git checkout develop
```
4. Traemos el contenido de develop a nuestro editor 
```
git pull origin develop
```
# Configuración del Entorno
1. Ingresamos a la configuracion de aws 
```
aws configure
```
2. Configuracion de credenciales
```
[su-perfil]
aws_access_key_id = SU_ACCESS_KEY
aws_secret_access_key = SU_SECRET_KEY
aws_session_token= SU_SESSION_TOKEN
region = us-east-1
```
3. Para verificamos que estamos en aws
```
aws sts get-caller-identity
```
4. Creamos un archivo terraform.tfvars para la lonfiguracion de variables ubicado en iac
```
alarm_email                = "email-verificado@gmail.com"
cognito_callback_urls      = [ "http://localhost:3000"]
environment                = "dev"
```
5. Dominio

| Variable     | Descripción                                     |
|-------------|--------------------------------------------------|
| domain_name | Dominio para CloudFront (Consersa.store)         |

6. Al ser un dominio comprado en namecheap necesitaremos los Nameservers que se ven algo asi
```
ns-xxxx.awsdns-xx.org
ns-xxxx.awsdns-xx.co.uk
ns-xx.awsdns-xx.com
ns-xxxx.awsdns-xx.net
```
estos ns los encontraremos dentro de aws en router53 en zonas alojadas, crearemos uno con el nombre de nuestro dominio
```
consersa.store
```
y luego de crearla debemos entrar y dentro en el registro tipo NS estaran, esos tendremos que copiarlo y en la pagina de  namecheap dodne compramos el dominio las podnremos, entrando a la opcion manage, ye en la parte que diga NAMESERVERS, seleccionamos Custom DNS y colocamos las ns y guardamos, para verificar pondremos lo siguiente
```
nslookup -type=ns consersa.store
```
nos mostraria los 4 NS de AWS y todo estaria en orden, si no sale eso tendremos que esperar y volver a poner el comando ya que esto puede tardar un rato

# Test de vulnerabilidad
## checkov 
1. Descargamos la imagen de Checkov versión 3
```
docker pull bridgecrew/checkov:3
```
2. Ejecutamos checkov para escanear nuestro codigo
```
docker run --rm -v "direccion-de-carpeta:/tf" --workdir /tf bridgecrew/checkov:3 --directory /tf -o junitxml --output-file-path results.xml
```

# Configuracion para el despliegue
1. entramos a la carpeta iac
```
cd iac
```
2. Inicializar Terraform 
```
terraform init
```
3. Ordenamos el codigo 
```
terraform fmt
```
4. Validamos la infraestructura
```
terraform validate
```
5. Vemos que se va a crear, modificar o eliminar
```
terraform plan
```
6. Si no hay ningun error
```
terraform apply
```
Y confirmamos con yes

7. Al estar desplegando necesitaremos confirmar una subscripcion de aws para notificaciones que llegara al gmail colocado en alarm_email.