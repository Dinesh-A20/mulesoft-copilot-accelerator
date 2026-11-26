package com.enterprise.etl;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;

/** ERR-32, CON-32: keep iterable JDK Path objects inside this filesystem boundary. */
public final class CsvFiles {
    private CsvFiles() {}

    public static String createTemporary(String directory) throws IOException {
        Path output = Paths.get(directory).toAbsolutePath().normalize();
        Files.createDirectories(output);
        return Files.createTempFile(output, ".opportunities-", ".part").toString();
    }

    public static String publish(String temporary, String fileName) throws IOException {
        Path source = Paths.get(temporary).toAbsolutePath().normalize();
        if (!fileName.matches("opportunities-\\d{4}-\\d{2}-\\d{2}\\.csv")
                || !source.getFileName().toString().matches("\\.opportunities-.+\\.part")) {
            throw new IllegalArgumentException("Invalid CSV publication path.");
        }
        LocalDate.parse(fileName.substring("opportunities-".length(), fileName.length() - 4));
        Path destination = source.getParent().resolve(fileName);
        Files.move(source, destination, StandardCopyOption.ATOMIC_MOVE,
                StandardCopyOption.REPLACE_EXISTING);
        return destination.toString();
    }
}
