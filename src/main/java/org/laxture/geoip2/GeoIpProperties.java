package org.laxture.geoip2;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = GeoIpProperties.PREFIX)
public class GeoIpProperties {

    public static final String PREFIX = "spring.geoip";

    private String accountId;

    private String secret;

    public String getAccountId() {
        return accountId;
    }

    public void setAccountId(String accountId) {
        this.accountId = accountId;
    }

    public String getSecret() {
        return secret;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }
}
