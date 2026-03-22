#!/usr/bin/python3

if __name__== '__main__':

    outputString=""
    encrypted_flag="`d~~dbc<5vk=4:;=;9445;o954nil>?=lo8k:4<:h5p"
    for each in encrypted_flag:
        outputString = outputString + chr(ord(each) ^13)
        print(outputString)