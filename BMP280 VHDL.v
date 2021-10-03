PROCESS(clk, reset)
       VARIABLE busy_count  :  INTEGER RANGE 0 to 11;
       VARIABLE delay_count  :  INTEGER RANGE 0 to 1000000;

       BEGIN
       i2c_addr  <=  slave_addr; 
            IF reset = '0' THEN
              sensorData <= (OTHERS => '0');
              busy_count := 0;
              delay_count := 0; 
            ELSIF RISING_EDGE(clk) THEN
              busy_prev <= i2c_busy;
              IF(busy_prev = '0' AND i2c_busy = '1') THEN
                  busy_count := busy_count + 1;
              END IF;

            
              CASE busy_count IS
                  
                  WHEN 0 =>
                    i2c_ena <= '1';
                    i2c_rw <= '0'; -- write
                    i2c_data_wr <= x"0E";
                    delay_count := 0;
                    
                   
                  WHEN 1 =>
                    IF delay_count < 1000000 THEN
                        delay_count := delay_count + 1;
                        i2c_ena <= '0'; -- disable until the end of delay
                    ELSE
                        i2c_ena <= '1'; -- enable i2c module
                        i2c_rw  <= '0'; -- read until end of this case
                        i2c_data_wr <= x"00";
                        delay_count := 0;                                  
                    END IF;


                  WHEN 2 =>
                    IF delay_count < 1000000 THEN                         
                        delay_count := delay_count + 1;                    
                        i2c_ena <= '0'; -- disable until the end of delay  
                    ELSE                                                   
                      i2c_ena <= '1';
                      i2c_rw <= '0'; -- write
                      i2c_data_wr <= x"0F";
                      delay_count := 0;
                    END IF;                                                

                  WHEN 3 =>
                    IF delay_count < 1000 THEN
                        delay_count := delay_count + 1;
                        i2c_ena <= '0'; -- disable until the end of delay
                    ELSE
                        i2c_ena <= '1'; -- enable i2c module
                        i2c_rw  <= '0'; -- read until end of this case
                        i2c_data_wr <= x"00";
                        delay_count := 0;                                   
                    END IF;





                  WHEN 4 =>
                     IF delay_count < 1000 THEN                              
                        delay_count := delay_count + 1;                      
                        i2c_ena <= '0'; -- disable until the end of dela     
                     ELSE                                                    
                      i2c_ena <= '1';
                      i2c_rw <= '0'; -- write
                      i2c_data_wr <= x"0F";
                      delay_count := 0;
                     END IF;                                                

                  WHEN 5 =>
                    IF delay_count < 1000 THEN
                        delay_count := delay_count + 1;
                        i2c_ena <= '0'; -- disable until the end of delay
                    ELSE
                        i2c_ena <= '1'; -- enable i2c module
                        i2c_rw  <= '0'; -- read until end of this case
                        i2c_data_wr <= x"01";
                        delay_count := 0;                                    
                    END IF;


                  WHEN 6 =>
                      --i2c_addr <= slave_addr;                              
                    IF delay_count < 1000000 THEN
                        delay_count := delay_count + 1;
                        i2c_ena <= '0'; -- disable until the end of delay
                    ELSE
                      i2c_ena <= '1'; -- enable i2c module
                      i2c_rw  <= '0'; -- read until end of this case
                      i2c_data_wr <= x"00"; --reading the sensor manufacturer ID
                      delay_count := 0;
                    END IF;

                  WHEN 7 =>
                    IF delay_count < 1000 THEN
                        delay_count := delay_count + 1;
                        i2c_ena <= '0'; -- disable until the end of delay
                    ELSE
                        i2c_ena <= '1'; -- enable i2c module
                        i2c_rw  <= '1'; -- read until end of this case
                    END IF;

                  WHEN 8 =>
                    IF(i2c_busy = '0') THEN
                      sensorData(31 DOWNTO 24) <= i2c_data_rd;
                    END IF;

                  WHEN 9 =>
                    IF(i2c_busy = '0') THEN
                      sensorData(23 DOWNTO 16) <= i2c_data_rd;
                    END IF;

                  WHEN 10 =>
                    IF(i2c_busy = '0') THEN
                      sensorData(15 DOWNTO 8) <= i2c_data_rd;
                    END IF;

                  WHEN 11 =>
                    i2c_ena <= '0'; -- disable on last byte
                    IF(i2c_busy = '0') THEN
                      sensorData(7 DOWNTO 0) <= i2c_data_rd;
                      busy_count := 2;
                    END IF;
                WHEN OTHERS => NULL;
              END CASE;


            END IF;
    END PROCESS;
END Behavioral;