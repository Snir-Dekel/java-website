package com.example.final_website;

import org.apache.commons.io.output.ByteArrayOutputStream;

import java.util.zip.Deflater;

public class MyByteArrayCompress {
    public byte[] compressByteArray(byte[] bytes) {

        ByteArrayOutputStream baos = null;
        Deflater dfl = new Deflater();
        dfl.setLevel(Deflater.BEST_COMPRESSION);
        dfl.setInput(bytes);
        dfl.finish();
        baos = new ByteArrayOutputStream();
        byte[] tmp = new byte[4 * 1024];
        try {
            while (!dfl.finished()) {
                int size = dfl.deflate(tmp);
                baos.write(tmp, 0, size);
            }
        }

         finally {
            try {
                baos.close();
            }
            catch (Exception ignored) {
            }
        }

        return baos.toByteArray();
    }
}
