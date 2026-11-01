VALERIUS — ACTO I: EL QUE ESCUCHA AL BOSQUE
Proyecto de Ren'Py preparado para compilar como APK vertical en Android.

ESTADO
- Es el proyecto FUENTE. NO es un APK y NO ha sido compilado ni probado
  en una instalación real de Ren'Py.
- Incluye el guion íntegro del Acto I y una interfaz básica táctil.
- Incluye fondos y personajes PROVISIONALES hechos con formas geométricas
  de pixel art para que no falten recursos al ejecutar el prototipo.
- NO incluye música ni voces.

CÓMO CONSTRUIR EL APK EN LINUX (por ejemplo Linux Mint)
1. Descomprime el ZIP completo.
2. Instala Ren'Py SDK desde https://www.renpy.org/latest.html
3. Abre Ren'Py, entra en Preferences y define Projects Directory como la
   CARPETA QUE CONTIENE la carpeta Acto_I_Valerius (no el propio game/).
4. Selecciona «Valerius» en la lista de proyectos.
5. Haz «Launch Project» para probarlo en escritorio. Si hay errores,
   consulta el traceback que muestra Ren'Py.
6. En «Android», acepta descargar RAPT y en «Install SDK & Create Keys»
   instala el Android SDK y genera las claves de firma.
7. Si Ren'Py te pide configurar el proyecto («Configure»), elige:
   - Nombre: Valerius - Acto I
   - Paquete: com.valerius.actouno
   - Orientación: Portrait
   - Tienda: None
   Ya está incluido android.json con esta configuración inicial.
8. Selecciona «Universal APK» (NO Play Bundle / AAB).
9. Pulsa «Build Package». En el directorio de distribuciones aparecerá
   el .apk instalable, para transferirlo a un teléfono Android.

NOTAS IMPORTANTES
- Conserva y respalda de manera privada android.keystore y bundle.keystore
  que Ren'Py cree. Sin ellas no podrás actualizar el mismo paquete fácilmente.
- Si cambias assets o código, vuelve a generar el APK desde Ren'Py.
- Un APK Android no se instala en un iPhone. Para iOS se necesita un proceso
  de exportación distinto. Sí puedes probar este proyecto en Linux.
- La elección «Negociar (requiere explorar)» se conserva igual que en el
  guion: no tiene un requisito de exploración real todavía.
- El códice y reputaciones existen como variables del guion.

AJUSTE DE TEXTO
Se corrigió el texto «[ilegible]» para que Ren'Py lo muestre de forma
literal (escape [[) y no intente evaluar una variable inexistente.

PÁGINAS DE REFERENCIA
https://www.renpy.org/doc/html/android.html
https://www.renpy.org/doc/html/cli.html
