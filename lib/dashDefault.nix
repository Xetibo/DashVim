# Ensure settings by other people are not overwritten
{lib, ...}: value: lib.mkOverride 999 value
