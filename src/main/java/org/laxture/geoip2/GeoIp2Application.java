package org.laxture.geoip2;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(GeoIpProperties.class)
public class GeoIp2Application {

	public static void main(String[] args) {
		SpringApplication.run(GeoIp2Application.class, args);
	}

}
