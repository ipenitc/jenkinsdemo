package com.dipen.jenkinsdemo;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
class JenkinsDemoApplicationTests {

    @Test
    void contextLoads() {
    }
    @Test
    void testMathSuccess() {
        // A simple dummy test that always passes
        assertEquals(10, 5 + 5, "5 + 5 should equal 10");
    }
    @Test
    void testMathFailure() {
        // This will fail and stop your Jenkins pipeline
        assertEquals(11, 5 + 5, "This test is designed to fail!");
    }
}
