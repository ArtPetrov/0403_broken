FROM maven:3-eclipse-temurin-17 as ssl

COPY ./certificates/russian_trusted_root_ca_pem.crt /usr/local/share/ca-certificates/russian_trusted_root_ca_pem.crt
COPY ./certificates/russian_trusted_sub_ca_pem.crt /usr/local/share/ca-certificates/russian_trusted_sub_ca_pem.crt

RUN update-ca-certificates

RUN keytool -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias rugov1 -file /usr/local/share/ca-certificates/russian_trusted_root_ca_pem.crt
RUN keytool -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit -noprompt -trustcacerts -importcert -alias rugov2 -file /usr/local/share/ca-certificates/russian_trusted_sub_ca_pem.crt

FROM ssl as build
WORKDIR /app
COPY . .
RUN mvn verify

FROM ssl
WORKDIR /app
COPY --from=build /app/target/client-jar-with-dependencies.jar ./client.jar

ENTRYPOINT ["java", "-jar", "client.jar"]