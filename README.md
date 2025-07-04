# Spring Boot + JPA + Liberty InstantOn Demo

This project shows how to use Liberty InstantOn with SpringBoot applications that load resources like Datasources at startup. The trick is to use a CRaC bean to close those resources that depend on the environment before the checkpoint and open them after restore:

```java
  // CracDataSourceHandler.java

  @Override
  public void beforeCheckpoint(Context<? extends Resource> context) throws Exception {
    dataSource.getConnection().close();
    System.out.println("Closed DataSource before checkpoint");
  }

  @Override
  public void afterRestore(Context<? extends Resource> context) throws Exception {
    dataSource.getConnection().isValid(1);
    System.out.println("Reconnected DataSource after restore");
  }
```

To be able to use CRaC it's needed to include this dependency in `pom.xml`:

```xml
    <dependency>
      <groupId>org.crac</groupId>
      <artifactId>crac</artifactId>
      <version>1.4.0</version>
    </dependency>
```

## Requirements

- Java 17+
- Maven
- Podman

## Build application

```bash
./mvn clean package
```

## Build Docker image with chekpoint

```bash
sudo podman build \
        -t dev.local/liberty-app-instanton \
        --cap-add=CHECKPOINT_RESTORE \
        --cap-add=SYS_PTRACE \
        --cap-add=SETPCAP \
        --security-opt seccomp=unconfined .
```

## Run container

```bash
sudo podman run \
        --rm \
        --cap-add=CHECKPOINT_RESTORE \
        --cap-add=SETPCAP \
        --security-opt seccomp=unconfined \
        -p 9080:9080 \
        liberty-app-instanton
```

## API REST

| Method | Endpoint        | Description     |
| ------ | --------------- | --------------- |
| GET    | /api/users      | List all users  |
| POST   | /api/users      | Create new user |
| GET    | /api/users/{id} | Get user        |
| DELETE | /api/users/{id} | Delete user     |

