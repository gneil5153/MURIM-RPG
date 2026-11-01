# Interfaz táctil ligera; evita depender de gui/ y screens del template.
# Los gráficos y colores son provisionales.

screen main_menu():
    tag menu
    add "images/bg_bosque.png"
    add Solid("#05080cb3")
    vbox:
        xalign 0.5
        yalign 0.43
        xsize 650
        spacing 28
        text "VALERIUS" xalign 0.5 size 76 color "#f1d9a2" bold True
        text "ACTO I  ·  EL QUE ESCUCHA AL BOSQUE" xalign 0.5 text_align 0.5 size 27 color "#e6d1da"
        null height 55
        textbutton "EMPEZAR" action Start() style "mobile_button"
        textbutton "CARGAR PARTIDA" action ShowMenu("load") style "mobile_button"
        textbutton "SALIR" action Quit(confirm=True) style "mobile_button"
    text "Demo narrativa · gráficos provisionales" xalign 0.5 yalign 0.95 size 20 color "#ddd0cc"

screen say(who, what):
    window:
        id "window"
        xalign 0.5
        yalign 1.0
        xsize 700
        ysize 348
        background Solid("#0b111bef")
        left_padding 32
        right_padding 32
        top_padding 30
        bottom_padding 18
        vbox:
            spacing 12
            if who is not None:
                text who id "who" size 40 color "#e4c6e7" bold True
            text what id "what" size 30 color "#f6efea" line_spacing 5

screen choice(items):
    modal True
    add Solid("#03070cc4")
    frame:
        xalign 0.5
        yalign 0.5
        xsize 688
        background Solid("#101925f7")
        padding (20, 28)
        viewport:
            ymaximum 960
            mousewheel True
            draggable True
            scrollbars "vertical"
            vbox:
                spacing 17
                for i in items:
                    if i.action:
                        textbutton i.caption action i.action style "mobile_button"
                    else:
                        text i.caption xalign 0.5 text_align 0.5 size 31 color "#f1d9a2"

screen nvl(dialogue, items=None):
    add Solid("#050a11bf")
    frame:
        xalign 0.5
        yalign 0.46
        xsize 675
        background Solid("#101622ef")
        padding (24, 26)
        viewport:
            ymaximum 800
            mousewheel True
            draggable True
            vbox:
                spacing 15
                for d in dialogue:
                    window:
                        id d.window_id
                        background None
                        xfill True
                        vbox:
                            if d.who is not None:
                                text d.who id d.who_id size 32 color "#f1d9a2"
                            text d.what id d.what_id size 30 color "#f6efea" line_spacing 4
                if items:
                    for i in items:
                        if i.action:
                            textbutton i.caption action i.action style "mobile_button"
                        else:
                            text i.caption size 28 color "#f6efea"

screen quick_menu():
    zorder 100
    if not main_menu:
        hbox:
            xalign 0.5
            ypos 10
            spacing 14
            textbutton "Guardar" action ShowMenu("save") style "small_button"
            textbutton "Cargar" action ShowMenu("load") style "small_button"
            textbutton "Menú" action MainMenu(confirm=True) style "small_button"

screen save():
    tag menu
    use file_menu("GUARDAR PARTIDA", save_mode=True)

screen load():
    tag menu
    use file_menu("CARGAR PARTIDA", save_mode=False)

screen file_menu(title, save_mode=False):
    add Solid("#071018")
    vbox:
        xalign 0.5
        yalign 0.42
        spacing 24
        text title xalign 0.5 size 44 color "#f1d9a2"
        for slot in range(1, 7):
            if save_mode:
                textbutton "Ranura [slot]" action FileSave(slot) style "mobile_button"
            else:
                textbutton "Ranura [slot]" action FileLoad(slot) style "mobile_button"
        textbutton "VOLVER" action Return() style "mobile_button"

screen confirm(message, yes_action, no_action):
    modal True
    zorder 200
    add Solid("#03060ae8")
    vbox:
        xalign 0.5
        yalign 0.5
        xsize 620
        spacing 28
        text message xalign 0.5 text_align 0.5 size 31 color "#f6efea"
        textbutton "SÍ" action yes_action style "mobile_button"
        textbutton "NO" action no_action style "mobile_button"

screen notify(message):
    zorder 100
    frame:
        xalign 0.5
        ypos 150
        background Solid("#121926f2")
        padding (20, 12)
        text message size 24 color "#ffffff"
    timer 3.0 action Hide("notify")

screen input(prompt):
    window:
        has vbox
        text prompt
        input id "input"

style mobile_button is button:
    xsize 620
    yminimum 90
    padding (22, 18)
    background Solid("#263245")
    hover_background Solid("#4e4564")
    insensitive_background Solid("#24272a")

style mobile_button_text is button_text:
    size 29
    color "#f6efea"
    hover_color "#ffe5a2"
    insensitive_color "#777777"
    text_align 0.5
    xalign 0.5

style small_button is button:
    xminimum 185
    yminimum 54
    padding (12, 8)
    background Solid("#0a1426df")
    hover_background Solid("#303e53")

style small_button_text is button_text:
    size 23
    color "#f7eeee"
    text_align 0.5
    xalign 0.5

init python:
    if "quick_menu" not in config.overlay_screens:
        config.overlay_screens.append("quick_menu")
