# Validación de esquema (parámetro obligatorio)
curl -v -X 'GET' 'http://petstore.fortidemoscloud.com/api/pet/findByStatus' -H 'accept: application/json'

# Validación de esquema (tamanño minimo de parámetro)
curl -v -X 'GET' 'http://petstore.fortidemoscloud.com/api/pet/findByStatus?status=A' -H 'accept: application/json'

# Validación de esquema (tamanño máximo de parámetro)
curl -v -X 'GET' 'http://petstore.fortidemoscloud.com/api/pet/findByStatus?status=AAAAAAA' -H 'accept: application/json'

# XSS en parámetros
curl -v -X 'GET' 'http://petstore.fortidemoscloud.com//api/pet/findByStatus?status=<script>alert(123)</script>' \
 -H 'Accept: application/json' -H 'Content-Type: application/json'

# XSS en body
curl -v -X 'POST' 'http://petstore.fortidemoscloud.com/api/pet' \
-H 'accept: application/json'  -H 'Content-Type: application/json' \
-d '{"id": 111, "category": {"id": 111, "name": "Camel"}, "name": "FortiCamel", "photoUrls": ["WillUpdateLater"], "tags": [ {"id": 111, "name": "FortiCamel"}], "status": "<script>alert(123)</script>"}'

