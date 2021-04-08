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
donnesBrutes = readtable('Analyse-de-données-météo-Montréal-McTavish.xlsx');

%% Moyenne des temperatures horaires par mois
% Création d'un ensemble de cellules pour les données moyennées par heure
meteo = {};
for i = 1:12
    % Prise en compte des heures écoulées dans l'année
    if i == 1
        lignesAccu(i) = 0;
    else
        lignesAccu(i) =  24*str2num(cell2mat(table2array(donnesBrutes(3,i+3))))+lignesAccu(i-1);
    end
    % Attribution des noms des mois aux cellules de la première colonne
    meteo{i,1}= table2array(donnesBrutes(2,i+4));
    
    % Sélection des données du tableau original selon l'heure du jour et le
    % mois
    tempMoy = [];
    for j = 1:24
            n = 1;
        for k = lignesAccu(i)+1:24:lignesAccu(i)+str2num(cell2mat(table2array(donnesBrutes(3,i+4))))*24
            tempMoy(j,n) = str2num(cell2mat(table2array(donnesBrutes(1+j+k,2))));
            n = n+1;
        end
    end
    % Moyenne mensuelle des données horaires
    meteo{i,2} = mean(tempMoy');
end

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
