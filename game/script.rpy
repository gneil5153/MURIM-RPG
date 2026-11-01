# ============================================================
# ACTO I — REGIO SILVAE / "El que escucha al bosque"
# ============================================================

define v = Character("Valerius", color="#c8a2c8")
define corvus = Character("Frater Corvus", color="#d4af37")
define prior = Character("Prior Anciano", color="#a9a9a9")
define bruno = Character("Bruno", color="#8b4513")
define guardian = Character("Monje Guardián", color="#808080")
define joven = Character("Monje Joven", color="#87ceeb")
define narr = Character(None, kind=nvl)

default reputation_pueblo = 0
default reputation_orden = 0
default lenadores_ayudados = False
default arbol_protegido = False
default negociacion_exitosa = False
default conflicto_ignorado = False
default prior_hint_north = False
default corvus_requested_information = False
default corvus_saw_symbol = False
default heard_corvus_rumor = False
default codex = []

label start:
    scene black with fade
    centered "{size=+20}ACTO I{/size}\n{size=+10}El que escucha al bosque{/size}\n\n{size=-5}Regio Silvae{/size}"
    with dissolve
    pause 2.0
    jump scene_1_1

label scene_1_1:
    scene bg_bosque with fade
    narr "Niebla baja. Raíces que parecen manos. El camino cruje bajo tus botas."
    v "Tres años. Tres años buscando tu rastro, hermano. Y la última pista me trae a un bosque que huele a moho y a plegaria."
    show valerius at center
    v "Aún me queda esencia. Bien. Que no se agote."
    "Un lobo emerge de la maleza. Sus ojos brillan con un brillo antinatural."
    menu:
        "¿Cómo reaccionas?"
        "Desenvainar y atacar con la espada":
            v "Acero primero."
            "Un golpe limpio. El lobo cae."
            $ codex.append("Los antiguos: nombre genérico que la gente da a los habitantes de las ruinas.")
        "Lanzar magia (cuesta esencia)":
            v "Que arda."
            "El lobo huye con el pelaje chamuscado. Te has quedado sin algo de esencia."
            $ codex.append("Los antiguos: nombre genérico que la gente da a los habitantes de las ruinas.")
        "Esquivar y seguir el camino":
            v "No es mi pelea."
            "El lobo te sigue un rato con la mirada, pero no ataca."
            $ codex.append("Los antiguos: nombre genérico que la gente da a los habitantes de las ruinas.")
    "El camino se abre. Frente a ti, entre la niebla, se alza el Monasterio de la Luz."
    jump scene_1_2

label scene_1_2:
    scene bg_monasterio with fade
    narr "Antorchas. Monjes que rezan en latín. Un hombre de mediana edad, sonrisa amable y manos limpias, se acerca."
    show corvus at center
    corvus "Un viajero con espada y magia. Poco común en estas tierras. ¿Buscas refugio o respuestas?"
    menu:
        corvus "¿Buscas refugio o respuestas?"
        "Busco a mi hermano.":
            v "Busco a mi hermano."
            corvus "¿Un hermano? Los bosques se tragan a muchos hombres. ¿Tienes algo que lo identifique?"
        "Busco respuestas.":
            v "Busco respuestas."
            corvus "Las respuestas son caras en estos tiempos. Pero quizá podamos encontrarlas juntos."
    "Sacas la carta arrugada. La muestras."
    v "Llevaba esto."
    "Corvus mira el símbolo un segundo de más. El jugador no lo nota. Pero la cámara se detiene."
    $ corvus_saw_symbol = True
    corvus "Ese símbolo... aparece en las ruinas del templo. La orden las custodia. Los monjes dicen que son herejías. Yo digo que son historia."
    corvus "Puedes ver las ruinas. Pero antes, quizá puedas ayudarnos con un problema terrenal. Los leñadores quieren talar el bosque sagrado. La orden lo prohíbe. Ambos tienen razón y ambos se equivocan. Un hombre con espada y magia podría mediar."
    "Corvus te entrega una insignia de la orden."
    menu:
        "Antes de irte, ¿examinas algo?"
        "Hablar con un monje joven":
            show joven at right
            joven "Frater Corvus no siempre fue tan... servicial. Desde que su hermano fue elegido jefe de la orden, ha cambiado."
            v "...¿Su hermano es el jefe de la orden?"
            joven "Sí. Y desde entonces, Corvus sonríe más. Y no me gusta."
            $ heard_corvus_rumor = True
            $ codex.append("Corvus: hermano del jefe de la orden. Ha cambiado desde que su hermano fue elegido.")
        "Examinar el altar":
            "Un altar con símbolos que no reconozco. No son de la orden. Son más antiguos."
            $ codex.append("Altar del monasterio: símbolos más antiguos que la propia orden.")
        "Salir directamente al bosque":
            v "No hay tiempo que perder."
    "Sales del monasterio. El bosque espera."
    jump scene_1_3

label scene_1_3:
    scene bg_claro with fade
    narr "Un claro del bosque. Un árbol enorme, marcado con símbolos antiguos. Leñadores y monjes discuten frente a él."
    show bruno at left
    show guardian at right
    bruno "Necesitamos madera o el invierno nos mata. Vuestro templo no nos da de comer."
    guardian "Ese árbol marca el límite de lo sagrado. Si taláis, despertaréis lo que duerme debajo."
    bruno "¡Cuentos! ¡Como los de los antiguos! ¡Cuentos para que no toquemos vuestro bosque!"
    narr "Todos los ojos se vuelven hacia ti."
    menu:
        "¿Qué decides?"
        "Apoyar a los leñadores":
            v "El pueblo necesita comer. Talad el árbol."
            bruno "¡Por fin alguien con sentido común!"
            guardian "Que los dioses te perdonen."
            $ reputation_pueblo += 2
            $ reputation_orden -= 2
            $ lenadores_ayudados = True
            "Los leñadores talan el árbol. El pueblo sobrevive el invierno."
            "La orden pierde autoridad en el bosque."
        "Apoyar a la orden":
            v "El árbol se queda. Buscad madera en otra parte."
            guardian "Gracias, hijo."
            bruno "Nos condenas al hambre."
            $ reputation_pueblo -= 2
            $ reputation_orden += 2
            $ arbol_protegido = True
            "El árbol no se tala. El pueblo pasa hambre."
            "El monje guardián te lo agradece. Bruno te maldice."
        "Negociar (requiere explorar)":
            v "Esperad. Buscaré otro bosque."
            "Exploras durante horas. Encuentras un bosque menor, talable, junto a una ruina antigua."
            "Pero en la ruina, grabado en la piedra, está el símbolo de tu hermano."
            $ reputation_pueblo += 1
            $ reputation_orden += 1
            $ negociacion_exitosa = True
            $ codex.append("Ruina menor: junto al bosque alternativo. Tiene el símbolo de la carta de Marcus.")
            guardian "Es... aceptable."
            bruno "Supongo que tendrá que servir."
            "Ambas partes aceptan a regañadientes."
        "Ignorar el conflicto":
            v "No es mi problema."
            "Te vas sin mediar. Esa noche, el bosque arde."
            $ reputation_pueblo -= 1
            $ reputation_orden -= 1
            $ conflicto_ignorado = True
            "Ninguno de los dos bandos te lo perdona."
    jump scene_1_4

label scene_1_4:
    scene bg_templo with fade
    narr "Raíces atraviesan piedra labrada. Inscripciones en una pared. Tú tocas el símbolo de tu carta. Coincide."
    v "Aquí está. El mismo símbolo. Y esto... esto no es latín. No es ninguna lengua que conozca."
    menu:
        "¿Qué inscripción lees?"
        "Leer la inscripción 1":
            "Los que vinieron de fuera no tenían nombre. Los que quedamos les dimos uno. Les llamamos... [[ilegible]."
            $ codex.append("Dos culturas: las inscripciones sugieren que hubo dos culturas, no una.")
            v "¿Dos culturas? La orden dice que solo hay una."
        "Leer la inscripción 2":
            "Cerramos la puerta con sangre. Que nunca se abra."
            $ codex.append("La puerta: mencionada en las inscripciones. 'Cerramos la puerta con sangre.'")
            v "¿La puerta? ¿Qué puerta?"
        "Leer ambas":
            "Los que vinieron de fuera no tenían nombre. Los que quedamos les dimos uno. Les llamamos... [[ilegible]."
            "Cerramos la puerta con sangre. Que nunca se abra."
            $ codex.append("Dos culturas: las inscripciones sugieren que hubo dos culturas, no una.")
            $ codex.append("La puerta: mencionada en las inscripciones. 'Cerramos la puerta con sangre.'")
            v "Esto no es una herejía. Es una advertencia."
    "Una voz a tu espalda."
    show prior at center
    prior "No deberías haber leído eso, hijo."
    v "¿Qué significa? ¿Qué puerta?"
    prior "...No lo sé. Y eso me aterra. Llevo cuarenta años rezando sobre estas piedras y cada año entiendo menos. La orden dice que son herejías de los antiguos. Pero yo he visto cosas en estos muros que... que no son herejías. Son advertencias."
    v "Mi hermano estuvo aquí. Busco a mi hermano."
    prior "...Sí. Un hombre con tu misma mirada. Preguntó lo mismo. Le dije lo mismo. Y se fue al norte, donde cavan sin miedo."
    v "¿Al norte? ¿Por qué al norte?"
    prior "Porque dijo que 'la respuesta está donde la piedra sangra'. No sé qué quiso decir. Reza para que tú sí lo sepas."
    $ prior_hint_north = True
    $ codex.append("Pista del prior: Marcus fue al norte. 'La respuesta está donde la piedra sangra'.")
    "Encuentras un fragmento de diario entre las piedras. La letra es de tu hermano."
    v "«No son ruinas. Es una puerta. Y alguien quiere abrirla desde dentro. Si lees esto, hermano, no vengas. Sella la cámara. No dejes que la abran. Te quiero. —M.»"
    v "...Marcus. Te encontré. Y sigues diciéndome qué hacer."
    $ codex.append("Fragmento de diario de Marcus: menciona 'la puerta' y 'los que vienen'.")
    jump scene_1_5

label scene_1_5:
    scene bg_camino with fade
    narr "Atardece. Corvus te despide en el camino."
    show corvus at center
    corvus "Al norte, ten cuidado. La gente de allí excava lo que no debe. Y no siempre son las piedras las que se quejan."
    v "¿Has estado allí?"
    corvus "Una vez. Volví cambiado, dicen. No sé si para bien."
    "Pausa. Corvus sonríe."
    corvus "Ve con Dios, Valerius. Y si encuentras lo que buscas... cuéntamelo."
    $ corvus_requested_information = True
    "La última frase se queda flotando en el aire."
    v "(«Cuéntamelo». Como si tuviera derecho a saberlo.)"
    jump fin_acto_1

label fin_acto_1:
    scene black with fade
    centered "{size=+15}FIN DEL ACTO I{/size}\n\n{size=+5}El que escucha al bosque{/size}\n\n{size=-5}Regio Silvae{/size}"
    pause 3.0
    centered "{size=+10}RESUMEN DE DECISIONES{/size}"
    if lenadores_ayudados:
        "Apoyaste a los leñadores. El pueblo sobrevivió el invierno."
    elif arbol_protegido:
        "Apoyaste a la orden. El árbol sigue en pie. El pueblo pasó hambre."
    elif negociacion_exitosa:
        "Negociaste. Ambas partes aceptaron a regañadientes."
    elif conflicto_ignorado:
        "Ignoraste el conflicto. El bosque ardió esa noche."
    centered "Reputación con el pueblo: [reputation_pueblo]"
    centered "Reputación con la orden: [reputation_orden]"
    centered "{size=+10}CÓDICE{/size}"
    $ codex_text = "\n\n".join(codex) if codex else "Vacío."
    centered "[codex_text]"
    centered "{size=+15}CONTINUARÁ...{/size}\n\n{size=-5}Acto II — Regio Borealis{/size}"
    return
