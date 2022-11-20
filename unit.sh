rojo build -o ./out.rbxl
echo "Running"
echo -e "[\\e[1;33m Tests \\e[0m]:"
VAL=$(run-in-roblox --place ./out.rbxl --script ./test/HEAD.lua)
echo -e "${VAL}"
echo -e "[\\e[1;33m Completed \\e[0m]"
rm out.rbxl
