# Investigación: Backup y restore. Backup en línea.

Aplicado al Sistema de Servicio Técnico Informático

---

## Creación de una copia de seguridad completa de la base de datos

Limitaciones

* La instruccion `BACKUP` no se permite en una transacción explícita o implícita.
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
