from z3 import *

import sys
import io  
#Juan Diego Mendoza Reyes

#Nota no he hecho el input de datos por falta de tiempo, lo siento

# Datos del problema
Meses = 5

N = 100
R = 6

VALOR =  [150,180,160,140,170]
MinB = 100000
MAXV = 200
MAXN = 250
MCAP = 1000
CA = 5
MinD = 3
MaxD = 6

# Precios de los aceites en cada mes y dureza de cada tipo de aceite
precios = [ 
  [110, 120, 130, 110, 115],
  [ 130, 130, 110, 90, 115],
  [ 110, 140, 130, 100, 95],
  [ 120, 110, 120, 120, 125],
  [ 100, 120, 150, 110, 105]]

dureza = [8.8, 6.1, 2.0, 4.2, 5.0]

# Cantidad de aceite crudo inicial y cantidad final de aceite crudo almacenado
cantidad_inicial = [500, 500, 500, 500, 500]
cantidad_final = [0, 0, 0, 0, 0]

# Crear variables de decisión
compras = [[Int("compras_%d_%d" % (m, i)) for i in range(5)] for m in range(Meses)]
refinadoV = [[Int("refinadoV_%d_%d" % (m, i)) for i in range(2)] for m in range(Meses)]
refinadoNV = [[Int("refinadoNV_%d_%d" % (m, i)) for i in range(3)] for m in range(Meses)]
produccion = [Int("produccion_%d" % m) for m in range(Meses)]
beneficio = Int("beneficio")

# Crear solver de Z3
solver = Solver()

# Restricciones de capacidad de almacenamiento
for i in range(5):
  solver.add(cantidad_inicial[i] + sum([compras[m][i] for m in range(Meses)]) == sum([refinadoV[m][0] for m in range(Meses)]) + sum([refinadoNV[m][0] for m in range(Meses)]))
  solver.add(cantidad_final[i] == cantidad_inicial[i] + sum([refinadoV[m][1] for m in range(Meses)]) + sum([refinadoNV[m][2] for m in range(Meses)]))
  solver.add(cantidad_final[i] <= MCAP)

# Restricciones de capacidad de refinado
for m in range(Meses):
  solver.add(sum([refinadoV[m][i] for i in range(2)]) <= MAXV)
  solver.add(sum([refinadoNV[m][i] for i in range(3)]) <= MAXN)

# Restricciones de balance de aceite crudo
for i in range(5):
  solver.add(cantidad_inicial[i] + sum([compras[m][i] for m in range(Meses)]) == sum([refinadoV[m][0] for m in range(Meses)]) + sum([refinadoNV[m][0] for m in range(Meses)]))

# Cambio:
#Restriccion perdidas solo en el ultimo mes
beneficio >= (MinB - sum(sum([compras[Meses-1][i] * precios[Meses-1][i] for i in range(5)]) + 
  sum(refinadoV[Meses-1][i] * CA for i in range(2)) + sum(refinadoNV[Meses-1][i] * CA for i in range(3))));

# Restriccion de menor porcentaje de aceites ANV a N por ciento del total refinado
for m in range(Meses):
  solver.add(sum([refinadoNV[m][i] for i in range(3)]) <= (N/100) * sum([refinadoV[m][i] for i in range(2)]) +
  sum([refinadoNV[m][i] for i in range(3)]));

# Restricciones de producción de producto final
for m in range(Meses):
    solver.add(sum(dureza[i] * refinadoV[m][i] for i in range(2)) +
          sum(dureza[i] * refinadoNV[m][i] for i in range(3)) >= MinD * produccion[m])
    solver.add(sum(dureza[i] * refinadoV[m][i] for i in range(2)) +
          sum(dureza[i] * refinadoNV[m][i] for i in range(3)) <= MaxD * produccion[m])

# Restricción de beneficio mínimo
solver.add(beneficio >= MinB)


# Resolver el problema y obtener la solución
if solver.check() == sat:
  modelo = solver.model()
  print("Solución encontrada")
else:
  print("No se encontró solución al problema.")