import re
import math


class Paginas:
    def get_numPaginas(self, texto):
        p = re.compile("Localizadas (\d+) ayudas")
        result = p.search(texto)
        
        return math.ceil(int(result.group(1))/5)
    
    
    def get_idAyuda(self, enlace):
        p = re.compile(".*=(\d+)&.*")
        result = p.search(enlace)
        
        return result.group(1)

