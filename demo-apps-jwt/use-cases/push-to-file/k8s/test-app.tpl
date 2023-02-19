spring:
  datasource:
    url: {{ secret "address" }}
    username: {{ secret "username" }}
    password: {{ secret "password" }}