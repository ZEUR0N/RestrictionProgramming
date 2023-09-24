%Juan Diego Mendoza Reyes

%NOTA: Se asumen que son solo 6 meses

% EXTRA:
int: meses = 5;
int : N; % Porcentaje minimo
int: R; %Numero maximo de meses consecutivos

% Precios de los aceites crudos
% [VEG 1, VEG 2, ANV 1, ANV 2, ANV 3]
% Precios: array[Meses, Aceites] of int
array[1..meses, 1..5] of int: precios;
% Dureza de los aceites crudos
% [VEG 1, VEG 2, ANV 1, ANV 2, ANV 3]
array[1..5] of float: dureza;

% Capacidad máxima de refinado por mes para cada tipo de aceite crudo
int: MAXV;
int: MAXN;

% Capacidad de almacenamiento para cada tipo de aceite crudo al inicio de cada mes
int: MCAP;

% Costo de almacenamiento de cada tipo de aceite crudo por tonelada y mes
int: CA;

% Cantidad inicial de cada tipo de aceite crudo almacenado
% [VEG 1, VEG 2, ANV 1, ANV 2, ANV 3]
array[1..5] of int: inicial;

% Precio de venta del producto final por tonelada
array[1..meses] of int: VALOR;

% Mínimo beneficio a conseguir
int: MinB;

%Minimo y maximo de durezas
float: MinD;
float: MaxD;

% Definición de variables

% Cantidad de cada tipo de aceite crudo comprado en cada mes y para entrega inmediata o en mercados futuros
% [mes, aceite]
array[1..meses, 1..5] of var 0..MCAP: compras;

% Cantidad de cada tipo de aceite crudo refinado en cada mes
% [mes, aceite]
array[1..meses, 1..5] of var 0..MAXV: refinadoV;
array[1..meses, 0..4] of var 0..MAXN: refinadoNV;

% Cantidad de producto final producido en cada mes
% [mes]
array[1..meses] of var int: produccion;

% Beneficio total conseguido
var int: beneficio;

% Definición de restricciones
% Restricciones de balance de aceite crudo
constraint forall (i in 1..5) (
  inicial[i] + sum([compras[k, i] | k in 1..meses]) == sum([refinadoV[k, i] | k in 1..meses]) + sum([refinadoNV[k, i - 1] | k in 1..meses])
);

% Restricciones de producción de producto final
constraint forall (m in 1..meses) (
  sum([dureza[i] * refinadoV[m, i] | i in 1..2]) +
  sum([dureza[i + 2] * refinadoNV[m, i] | i in 0..2]) >= MinD * produccion[m] /\ 
  sum([dureza[i] * refinadoV[m, i] | i in 1..2]) +
  sum([dureza[i + 2] * refinadoNV[m, i] | i in 0..2]) <= MaxD * produccion[m]
);

% Restricción de beneficio mínimo
constraint beneficio >= MinB;

int: K = 3;   % Número máximo de aceites a utilizar
int: T = 100; % Toneladas mínimas de aceite a utilizar cada mes

% Restricción de cantidad mínima de aceite a utilizar por mes
constraint forall (m in 1..meses, i in 1..5) (
  refinadoV[m, i] + sum([refinadoNV[m, j] | j in 0..2]) >= bool2int(inicial[i] + sum([compras[k, i] | k in 1..meses]) >= T)
);

% Restricción de número máximo de aceites a utilizar
constraint forall (m in 1..meses) (
  sum([bool2int(refinadoV[m, i] > 0) | i in 1..2]) +
  sum([bool2int(refinadoNV[m, i] > 0) | i in 0..2]) <= K
);

% Restricción de aceites ANV 1, ANV 2 y VEG 2
constraint forall (m in 1..meses) (
  (sum([refinadoNV[m, i] | i in 1..2]) > 0) -> (refinadoV[m, 2] + refinadoNV[m, 0] > 0)
  );

% Cambio:
%Restriccion perdidas solo en el ultimo mes
constraint beneficio >= (MinB - sum([sum([compras[5,i] * precios[5,i] | i in 1..5]) + 
  sum([refinadoV[5,i] * CA | i in 1..2]) + sum([refinadoNV[5,i]*CA |i in 1..3]) | m in 1..meses]));

% Restriccion de menor porcentaje de aceites ANV a N por ciento del total refinado
constraint (sum([refinadoNV[m,i] | m in 1..5, i in 1..3]) <= (N/100) * sum([refinadoV[m,i] | m in 1..5, i in 1..2]) +
  sum([refinadoNV[m,i] |m in 1..5, i in 1..3]));

%Restriccion de impide el uso del mismo aceite más de R meses en total
 array [1..5] of var 1..5: ultimo_uso;
 constraint forall(m in 1..5, i in 1..5)(
 (ultimo_uso[i] < m /\ refinadoV[m, i] > 0) -> (ultimo_uso[i] + R >= m) /\
 (ultimo_uso[i] >= m \/ refinadoNV[m, i] = 0)
 );

% Definición de función de beneficio
function var int: calcular_beneficio() =
  sum([VALOR[m] * produccion[m] | m in 1..meses]) -
  sum([sum([compras[m, i] * precios[m, i] | i in 1..5]) + sum([refinadoV[m, i] * CA | i in 1..2]) + sum([refinadoNV[m, i] * CA | i in 0..2]) | m in 1..meses]);


% Definición de objetivo de maximización de beneficio
solve satisfy;


% Salida de resultados
output [  "Cantidad de aceite crudo comprado en cada mes:\n",  show(compras), "\n\n",  "Cantidad de aceite crudo refinado en cada mes:\n",  show(refinadoV), "\n", show(refinadoNV), "\n\n",  "Cantidad de producto final producido en cada mes:\n",  show(produccion), "\n\n",  "Beneficio total conseguido: ", show(beneficio)];
