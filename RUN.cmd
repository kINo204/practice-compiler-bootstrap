@echo off
java -jar mars.jar db compiler/compiler.asm && java -jar mars.jar db out/ret_2.asm 
pause