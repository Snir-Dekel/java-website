package com.example.final_website;

import org.apache.commons.io.output.ByteArrayOutputStream;

import java.util.zip.Inflater;

public class MyByteArrayDecompress {

    public byte[] decompressByteArray(byte[] bytes) {

        ByteArrayOutputStream baos = null;
        Inflater iflr = new Inflater();
        iflr.setInput(bytes);
        baos = new ByteArrayOutputStream();
        byte[] tmp = new byte[4 * 1024];
        try {
            while (!iflr.finished()) {
                int size = iflr.inflate(tmp);
                baos.write(tmp, 0, size);
            }
        }
        catch (Exception ex) {

        } finally {
            try {
                baos.close();
            }
            catch (Exception ignored) {
            }
        }

        return baos.toByteArray();
    }

}
