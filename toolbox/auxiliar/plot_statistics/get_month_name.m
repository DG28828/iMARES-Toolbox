function mes = get_month_name(month_names, m)
%get_month_name extrae nombre de mes, ya sea en formato cell o char.

if iscell(month_names)
    mes = month_names{m};
else
    mes = char(month_names(m));
end

end