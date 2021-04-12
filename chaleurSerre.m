%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% chaleurSerre.m
% Fonction calculant les besoins thermiques de la serre (kW)
% Inputs : - irrMoy (1x24) (vecteur de l'irraditiation moyenne par heure dans une
% journ�e)
% - tempMoy (1x24) (vecteur de la temp�rature moyenne ext�rieure par heure)
% - tempSerre (1x24) (vecteur de la temp�rature dans la serre par heure)
% - chargeLum (1x24) (vecteur de la charge d'�clairage par heure)
% Output : - qSerre (1x24) (vecteur de l'�nergie thermique requise par heure pour la serre sans ventilation naturelle)
% Auteurs : Dominic Rivest
% Date de cr�ation : 2021-04-09
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function qSerre = chaleurSerre(irrMoy, tempMoy, tempSerre, chargeLum)

% Param�tres de la serre
A_s = 44; % Aire de la serre (m2)
l_s = 4.4; % Largeur de la serre (m)
L_s = 10; % Longueur de la serre (m)
t_s = 0.29; % Transmitivit� plafond
Q_vf = 18.3; % D�bit d'air volum�trique des fans (m3a/m2_sh)
rho_a = 1.27; % Densit� de l'air (kg/m3
cp_a = 1.000; % Cp air kJ/kgK

% Initialisation des variables
qSerre = []; % Puissance thermique n�cessaire (kW)
q_rad = []; % Chaleur gagn�e par radiation (kW)
q_wall = []; % Chaleur perdue par les murs (kW)
q_soil = []; % Chaleur perdue par le sol (kW)
q_vf = []; % Chaleur perdue par la ventilation forc�e (kW)

for i = 1:length(irrMoy)
    q_rad = t_s*irrMoy(i)*A_s/1000;
    q_wall = (0.85*(tempSerre(i)-tempMoy(i))*(2*L_s+2*l_s))/1000;
    q_soil = 20.7/(3600)*A_s*(tempSerre(i)-tempMoy(i));
    q_vf = Q_vf*A_s*(tempSerre(i)-tempMoy(i))/3600*cp_a;
    qSerre(i) = q_wall+q_soil+q_vf-q_rad-chargeLum(i);
end

end