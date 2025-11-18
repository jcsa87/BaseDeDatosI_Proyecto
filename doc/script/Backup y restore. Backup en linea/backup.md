# Investigación: Backup y restore. Backup en línea.

Aplicado al Sistema de Servicio Técnico Informático

---

## Creación de una copia de seguridad completa de la base de datos

Limitaciones

* La instruccion `BACKUP` no se permite en una transacción explícita o implícita. Una transacción explícita es aquella en que se define explícitamente el inicio y el final de la transacción.

* Las copias de seguridad creadas por versiones más recientes de SQL Server no se pueden restaurar en versiones anteriores de SQL Server

Recomendaciones

* Para las bases de datos grandes, considere la posibilidad de complementar las copias de seguridad completas con una serie de copias de seguridad diferenciales, debido a que las completas requieren más tiempo para finalizar y más espacio de almacenamiento.
* Se puede calcular el tamaño de una copia de seguridad mediante el procedimiento almacenado del sistema sp_spaceused.

Seguridad

`TRUSTWORTHY` es una propiedad de base de datos que indica si el servidor confía en el contenido de esa base de datos, permitiendo que los módulos dentro de ella obtengan permisos que podrían ir más allá de sus límites de seguridad normales; esta por defecto se estaflece OFF en una copia de seguridad de base de datos. Para establecerlo en ON debes tener el permiso de `CONTROL SERVER` en la base de datos.

Permisos

De forma predeterminada, los permisos `BACKUP DATABASE` y `BACKUP LOG` se corresponden a los miembros del rol fijo de servidor *sysadmin* y de los roles fijos de base de datos *db_owner* y *db_backupoperator*.

Ejemplos 

```SQL
BACKUP DATABASE <database>
TO <backup_device> [ , ...n ]
[ WITH <with_options> [ , ...o ] ];
```
Entre las opciones WITH se encuentran:

* { COMPRESSION | NO_COMPRESSION }: solo especifica si la compresión de copia de seguridad se realiza en la copia de seguridad, reemplazando el valor predeterminado de nivel de servidor.

* CIFRADO (ALGORITMO, CERTIFICADO DE SERVIDOR | ASYMMETRIC KEY): especifica el algoritmo de cifrado que se va a usar y el certificado o la clave asimétrica que se va a usar para proteger el cifrado.

* DESCRIPTION = { '*text*' | @*text_variable* }: Especifica el texto de forma libre que describe el conjunto de copia de seguridad.

* NAME = { *backup_set_name* | @*backup_set_name_var* }. Especifica el nombre del conjunto de copia de seguridad. Si `NAME` no se especifica, está en blanco.


## Copia de seguridad de un registro de transacciones.

Limitaciones

* No se admiten las copias de seguridad del registro de transacciones de la base de datos del sistema `master`.

Ejemplos

```SQL
BACKUP LOG AdventureWorks2022
   TO MyAdvWorks_FullRM_log1;
GO
```

## Restore

# Escenarios de restauración
SQL Server admite una serie de escenarios de restauración, las utilizadas para la realización del trabajo fueron las siguientes:

* Restauración de la base de datos completa

Restaura la base de datos completa, empezando por una copia de seguridad completa de la base de datos, que puede ir seguida de una restauración de una copia de seguridad diferencial de la base de datos (y copias de seguridad de registros). 

* Restauración de archivos

Restaura un archivo o un grupo de archivos en una base de datos de varios grupos de archivos. En el modelo de recuperación simple, el archivo debe pertenecer a un grupo de archivos de solo lectura. Después de una restauración de archivos completa, se puede restaurar una copia de seguridad de archivos diferencial.

* Restauración por etapas

Restaura la base de datos por etapas, empezando por el grupo de archivos principal y uno o más grupos de archivos secundarios. Una restauración por etapas empieza por RESTORE DATABASE y la especificación de uno o más grupos de archivos secundarios que se van a restaurar.


* Restauración del registro de transacciones.

Con el modelo de recuperación completa o el modelo de recuperación optimizado para cargas masivas de registros, es necesaria la restauración de copias de seguridad de registros para alcanzar el punto de recuperación deseado.

Otro punto importante fue la opción [RECOVERY | NORECOVERY]:

*`NORECOVERY` especifica que la reversión no se produce. Esto permite la puesta al día para continuar con la siguiente instrucción de la secuencia.
En este caso, la secuencia de restauración puede restaurar otras copias de seguridad y ponerlas al día.

*`RECOVERY` (predeterminado) indica que se debe realizar la reversión una vez completada la puesta al día para la copia de seguridad actual. No se pueden restaurar más copias de seguridad. Esta opción debe ser seleccionada una vez que haya restaurado todas las copias de seguridad necesarias.