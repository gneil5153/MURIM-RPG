# Valerius — Acto I: opciones
# El tamaño 720×1280 lo fija gui.init en gui.rpy.
define config.name = _("Valerius — Acto I: El que escucha al bosque")
define config.version = "1.0"
define gui.show_name = True

define gui.about = _("""
Acto I de una aventura 2D pixel art medieval centrada en exploración
y decisiones morales.

Protagonista: Valerius Vindicta, mago espadachín.
Región: Regio Silvae.

Gráficos provisionales incluidos para poder ejecutar la demo.
""")

# Preferencias para dispositivos móviles.
define config.has_autosave = True
define config.autosave_slots = 3
define config.save_on_mobile_background = True
define config.nearest_neighbor = True
