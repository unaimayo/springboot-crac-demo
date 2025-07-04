package com.example.demo;

import jakarta.annotation.PostConstruct;
import org.crac.Context;
import org.crac.Resource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class CracDataSourceHandler implements Resource {

  @Autowired
  private DataSource dataSource;

  @PostConstruct
  public void register() {
    org.crac.Core.getGlobalContext().register(this);
  }

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
}

