# Bilingüe

Addon para **World of Warcraft: Forever** pensado para jugar con gente que tiene el juego en otro idioma. Dejás el mouse quieto un segundo y medio sobre algo y aparece, en celeste, cómo se llama en el otro idioma:

- si tu juego está en inglés, te muestra el nombre en español;
- si está en español, te muestra el nombre en inglés.

Así, cuando alguien te dice "andá a buscar *Flor de paz*", sabés que es *Peacebloom*.

## Instalar

1. Bajá **[Bilingue.zip](https://github.com/matud-ntc/Bilingue/releases/latest/download/Bilingue.zip)**. Usá ese link: el botón verde *Code → Download ZIP* y los *Source code* de la página de releases bajan una carpeta con otro nombre (`Bilingue-main`, `Bilingue-0.1.0`) que el juego no reconoce.
2. Abrí el zip y arrastrá la carpeta `Bilingue` que hay adentro a:
   `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\`
   Si usás *Extraer todo*, borrá del destino el `\Bilingue` que Windows agrega al final; si no, queda `AddOns\Bilingue\Bilingue` y el juego no lo ve. Tiene que quedar `AddOns\Bilingue\Bilingue.toc`.
3. Cerrá y abrí el juego. En la selección de personaje, en **AddOns**, fijate que esté tildado.

Para actualizar, repetí los mismos pasos y reemplazá la carpeta.

## Dónde aparece

- **Tooltips**: items (bolsas, vendedores, loot, subasta, links del chat), hechizos, talentos, buffs, NPCs y su título, hierbas, vetas y cofres.
- **Mapa del mundo**: la zona, subzona o mazmorra que tenés debajo del cursor.
- **Minimapa**: al pasar el mouse por el nombre de la zona.
- **Registro de misiones**: el título de cada misión y los nombres de zona.

Los nombres que son iguales en los dos idiomas (Durotar, Orgrimmar, Thrall) no muestran nada.

## Comandos

| Comando | Qué hace |
|---|---|
| `/bil flor de paz` | busca un nombre en los dos idiomas (no importan las tildes ni las mayúsculas) |
| `/bil delay 0.5` | cambia la espera antes de mostrar la traducción (`0` = al instante) |
| `/bil off` · `/bil on` | lo apaga y lo prende |

`/trad` funciona igual que `/bil`.

## Para desarrollo

Los nombres salen de las tablas del cliente de Forever ([wago.tools](https://wago.tools), inglés y español de Latinoamérica) y de [QuestieDB](https://github.com/Questie/QuestieDB) (NPCs, misiones, objetos). Cuando Forever cambia de parche hay que regenerarlos:

```
python3 scripts/build_data.py --build <versión>
```

La versión está en `World of Warcraft/.build.info`, en la línea de `wowf`. Necesita `lua5.4` y QuestieDB instalado (o `--questiedb <ruta>`).

Para publicar una versión: subir `## Version:` en `Bilingue/Bilingue.toc`, después `git tag vX.Y.Z && git push --tags`. GitHub Actions arma el zip y crea la release.

## Licencia

GPL-3.0. Los nombres de NPCs, misiones y objetos vienen de QuestieDB (GPL-3.0).
