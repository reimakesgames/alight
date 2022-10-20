echo ""
echo -e "\e[1;31mF5 Anything is a required VSCode extension"
echo -e "\e[1;31mVS Marketplace Link: https://marketplace.visualstudio.com/items?itemName=discretegames.f5anything"
echo -e "\e[0m"

rojo build -o ./out.rbxl
echo ""
echo "Running"
echo ""
echo -e "[ \\e[1;33mOutput\\e[0m ]:"
echo ""
VAL=$(run-in-roblox --place ./out.rbxl --script tester.lua)
# mf why can't i color shit here??
echo -e "${VAL}"
echo ""
echo -e "[ \\e[1;33mCompleted\\e[0m ]"
echo ""
rm out.rbxl
