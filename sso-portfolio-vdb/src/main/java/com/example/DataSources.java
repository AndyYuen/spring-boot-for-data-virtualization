package com.example;

import javax.sql.DataSource;

import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.teiid.spring.data.rest.RestConnectionFactory;

@Configuration
public class DataSources {

    @ConfigurationProperties(prefix = "spring.datasource.sampledb")
    @Bean
    public DataSource sampledb() {
        return DataSourceBuilder.create().build();
    }

    @Bean public RestConnectionFactory quotesvc() {
        return new RestConnectionFactory(); 
    }

}
