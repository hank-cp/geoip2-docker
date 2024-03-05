package org.laxture.geoip2;

import com.maxmind.db.CHMCache;
import com.maxmind.geoip2.DatabaseReader;
import com.maxmind.geoip2.exception.GeoIp2Exception;
import com.maxmind.geoip2.model.AsnResponse;
import com.maxmind.geoip2.model.CityResponse;
import com.maxmind.geoip2.model.CountryResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Mono;

import java.io.File;
import java.io.IOException;
import java.net.InetAddress;

@RestController
public class ProxyController {

    public static final String CITY_DATABASE_PATH = "/usr/share/GeoIP/GeoLite2-City.mmdb";
    public static final String ASN_DATABASE_PATH = "/usr/share/GeoIP/GeoLite2-ASN.mmdb";

    private DatabaseReader cityDatabaseReader;

    private DatabaseReader asnDatabaseReader;

    private DatabaseReader getCityDataBase() throws IOException {
        if (cityDatabaseReader == null) {
            File database = new File(CITY_DATABASE_PATH);
            cityDatabaseReader = new DatabaseReader.Builder(database).withCache(new CHMCache()).build();
        }
        return cityDatabaseReader;
    }

    private DatabaseReader getAsnDataBase() throws IOException {
        if (asnDatabaseReader == null) {
            File database = new File(ASN_DATABASE_PATH);
            asnDatabaseReader = new DatabaseReader.Builder(database).withCache(new CHMCache()).build();
        }
        return asnDatabaseReader;
    }

    @GetMapping(value = "/geoip/v2.1/country/{ipAddress}")
    public Mono<CountryResponse> country(@PathVariable String ipAddress) {
        try {
            InetAddress addr = InetAddress.getByName(ipAddress);
            return Mono.justOrEmpty(getCityDataBase().tryCountry(addr));
        } catch (IOException | GeoIp2Exception e) {
            return Mono.error(e);
        }
    }

    @GetMapping(value = "/geoip/v2.1/city/{ipAddress}")
    public Mono<CityResponse> city(@PathVariable String ipAddress) {
        try {
            InetAddress addr = InetAddress.getByName(ipAddress);
            return Mono.justOrEmpty(getCityDataBase().tryCity(addr));
        } catch (IOException | GeoIp2Exception e) {
            return Mono.error(e);
        }
    }

    @GetMapping(value = "/geoip/v2.1/asn/{ipAddress}")
    public Mono<AsnResponse> asn(@PathVariable String ipAddress) {
        try {
            InetAddress addr = InetAddress.getByName(ipAddress);
            return Mono.justOrEmpty(getAsnDataBase().tryAsn(addr));
        } catch (IOException | GeoIp2Exception e) {
            return Mono.error(e);
        }
    }

    @GetMapping(value = "/geoip/v2.1/reload")
    public Mono<Void> reload() {
        try {
            cityDatabaseReader = new DatabaseReader.Builder(new File(CITY_DATABASE_PATH)).withCache(new CHMCache()).build();
            asnDatabaseReader = new DatabaseReader.Builder(new File(ASN_DATABASE_PATH)).withCache(new CHMCache()).build();
            return Mono.empty();
        } catch (IOException e) {
            return Mono.error(e);
        }
    }

}
