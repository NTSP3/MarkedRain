echo -e "\n\e[36m               +++++++++++++++++ MRain Operating System +++++++++++++++++               \e[0m";
val_temp=" ShowCommand";
val_temp=${val_temp#"${val_temp%%[![:space:]]*}"};
val_temp2=${#val_temp};
val_temp3=" bool_show_cmd";
val_temp3=${val_temp3#"${val_temp3%%[![:space:]]*}"};
val_temp4=${#val_temp3}; val_temp2=$((val_temp2 + val_temp4));
if [ $val_temp2 -gt 34 ] || [ $((val_temp2 % 2)) -ne 0 ]; then
    echo -e "";
    echo -e "\e[1;37;41mError:\e[0m\e[1;91m Total length of characters ($val_temp2) supplied to definition \"true\" is greater than 34, or is not even.\e[0m";
    echo -e "";
    false;
else
    val_temp2=$(((52 - (val_temp2 + 4 + 14)) / 2));
    val_temp2=;
    echo -e "\n\e[32m               !**$val_temp2$val_temp ($val_temp3) is set to true$val_temp2**!               \e[0m";
fi
echo -e "\n\e[32m               !**  ShowAppOutput (bool_show_cmd_out) is set to true  **!               \e[0m";
echo -e "\n\e[36m               !**          Checking variable 'EXTRAVERSION'          **!               \e[0m";
echo -e "\n\n\e[36m    // Exporting superuser variable //\e[0m\n"
