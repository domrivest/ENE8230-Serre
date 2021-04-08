%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% optiSerre.m
% Programme d'optimisation d'une serre en microréseau
% Auteurs : Maxime Cecchini, Reda Kaoula, Absa Ndiaye, Marianne Perron,
% Dominic Rivest et Khalil Telhaoui
% Date de création : 2021-04-01
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc
clear
close all
%% Importation des paramètres environnemnentaux
load('DonneesMeteo.mat');

%% Moyenne des données météo horaires par mois
% Création d'un ensemble de cellules pour les données moyennées par heure
param = {}; %(par colonne : Mois, tempMoy, ventMoy, RhMoy, irrMoy, pvMoy, eolMoy)
joursMois = [31 28 31 30 31 30 31 31 30 31 30 31];
nomsMois = {'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'};

for i = 1:12
    % Prise en compte des heures écoulées dans l'année
    if i == 1
        lignesAccu(i) = 0;
    else
        lignesAccu(i) =  lignesAccu(i-1)+24*joursMois(i-1);
    end
    % Attribution des noms des mois aux cellules de la première colonne
    param{i,1}= nomsMois(i);
    
    % Sélection des données du tableau original selon l'heure du jour et le
    % mois
    tempMoy = [];
    ventMoy = [];
    RHMoy = [];
    irrMoy = [];
    for j = 1:24 %Indexation pour les heures de la journée
            n = 1;
            %Indexation pour les lignes accumulées
        for k = lignesAccu(i):24:lignesAccu(i)+joursMois(i)*24-24 
            tempMoy(j,n) = table2array(DonnesmteoVarennes(j+k,6));
            ventMoy(j,n) = table2array(DonnesmteoVarennes(j+k,3));
            RHMoy(j,n) = table2array(DonnesmteoVarennes(j+k,2));
            irrMoy(j,n) = table2array(DonnesmteoVarennes(j+k,5));
            n = n+1;
        end
    end
    % Moyenne mensuelle des données horaires
    param{i,2} = mean(tempMoy'); % Compilation des températures horaires moyennes (degrés C)
    param{i,3} = mean(ventMoy'); % Compilation des températures horaires moyennes (m/s)
    param{i,4} = mean(RHMoy'); % Compilation des humidités relative horaires moyennes (%)
    param{i,5} = mean(irrMoy'); % Compilation des irradiations horaires moyennes (W/m2?)
end

%% Puissances éoliennes et solaires horaires par mois
solaireTot = [];
eolienTot = [];
for i = 1:12
    % Énergie solaire produite par heure
    param{i,6} = energieSolaire(param{i,5},param{i,2});
    solaireTot(i) = sum(param{i,6});
    % Énergie éolienne produite par heure
    param{i,7} = energieEolienne(param{i,3});
    eolienTot(i) = sum(param{i,7});
end

solaireAnnuel = sum(solaireTot.*joursMois); %Énergie solaire annuelle
eolienAnnuel = sum(eolienTot.*joursMois); %Énergie éolienne annuelle
%% Entrée des paramètres du projet

Cap_i = [2100,1900,3000]; % Capacité du générateur i [MW]
CB_i = [400, 600, 500]; % Coût de base du générateur i [$]
C_i = [5,4,7]; % Coût d'opération du générateur i [$]
CD_i = [800, 1000, 700]; % Coût de démarrage du générateur i [$]
D_j = [4300, 3700, 3900, 4000, 4700]; % Demande d'électricité au jour j [MW]

%% Définition des variables du projet

s_ij = optimvar('s_ij',3,5,'Type','integer','LowerBound',0,'UpperBound',1);
y_ij = optimvar('y_ij',3,5,'Type','integer','LowerBound',0,'UpperBound',1);
x_ij = optimvar('x_ij',3,5,'LowerBound',0);

%% Définition de la fonction objectif du projet

prob = optimproblem('ObjectiveSense','min');

prob.Objective = sum(CD_i * s_ij + C_i * x_ij + CB_i * y_ij);

%% Définition des contraintes du projet
prob.Constraints.con_1 = x_ij(1,:) <= Cap_i(1) * y_ij(1,:);
prob.Constraints.con_2 = x_ij(2,:) <= Cap_i(2) * y_ij(2,:);
prob.Constraints.con_3 = x_ij(3,:) <= Cap_i(3) * y_ij(3,:);
prob.Constraints.con_4 = s_ij(:,1) == y_ij(:,1);
% prob.Constraints.con_5 = s_ij(1,2:end) >= y_ij(1,2:end) - y_ij(1,1:end-1);
% prob.Constraints.con_6 = s_ij(2,2:end) >= y_ij(2,2:end) - y_ij(2,1:end-1);
% prob.Constraints.con_7 = s_ij(3,2:end) >= y_ij(3,2:end) - y_ij(3,1:end-1);
prob.Constraints.con_5 = s_ij(:,2:end) >= y_ij(:,2:end) - y_ij(:,1:end-1);
prob.Constraints.con_8 = sum(x_ij) >= D_j;
%% Résolution du problème
[sol,fval] = solve(prob);
