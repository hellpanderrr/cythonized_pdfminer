STUFF = "HI"
# drange
cdef drange(float v0, float v1, int d):
    """Returns a discrete range."""
    assert v0 < v1
    return xrange(int(v0)//d, int(v1+d)//d)
cdef  float float_max(float a, float b): return a if a >= b else b
cdef  float float_min(float a, float b): return a if a <= b else b


cdef class Plane:
    cdef public list _seq
    cdef public set _objs 
    cdef dict _grid 
    cdef int gridsize
    cdef float x0,y0,x1,y1
    
    def __init__(self, bbox, gridsize=80):
        self._seq = []          # preserve the object order.
        self._objs = set()
        self._grid = {}
        self.gridsize = gridsize
        (self.x0, self.y0, self.x1, self.y1) = bbox
        return

    def __repr__(self):
        return ('<Plane objs=%r>' % list(self))

    def __iter__(self):
        return ( obj for obj in self._seq if obj in self._objs )

    def __len__(self):
        return len(self._objs)

    def __contains__(self, obj):
        return obj in self._objs
        
    #@memoize

    cpdef list _getrange(self, tuple bbox):
        cdef list ret
        cdef float x0,x1,y0,y1

        ret = []
        (x0, y0, x1, y1) = bbox
        if (x1 <= self.x0 or self.x1 <= x0 or
            y1 <= self.y0 or self.y1 <= y0): return
        x0 = float_max(self.x0, x0)
        y0 = float_max(self.y0, y0)
        x1 = float_min(self.x1, x1)
        y1 = float_min(self.y1, y1)
        for y in drange(y0, y1, self.gridsize):
            for x in drange(x0, x1, self.gridsize):
                ret.append((x, y))

        return ret

    # extend(objs)
    cpdef void extend(self, objs):
        for obj in objs:
            self.add(obj)
        return

    # add(obj): place an object.
    cpdef void add(self, obj):
        cdef tuple k
        cdef list r
        for k in self._getrange((obj.x0, obj.y0, obj.x1, obj.y1)):
            
            if k not in self._grid:
                r = []
                self._grid[k] = r
            else:
                r = self._grid[k]
            r.append(obj)
        self._seq.append(obj)
        self._objs.add(obj)
        return

    # remove(obj): displace an object.
    cpdef remove(self, obj):
        cdef tuple k
        for k in self._getrange((obj.x0, obj.y0, obj.x1, obj.y1)):
            try:
                self._grid[k].remove(obj)
            except (KeyError, ValueError):
                pass
        self._objs.remove(obj)
        return
    #@memoize
    # find(): finds objects that are in a certain area.
    

    cpdef list find(self, tuple bbox):
        cdef float x0,y0,x1,y1
        cdef set done
        cdef tuple k
        (x0, y0, x1, y1) = bbox
        done = set()
        cdef object obj
        cdef list ret
        ret = []
        for k in self._getrange(bbox):
            if k not in self._grid:
                continue
            for obj in self._grid[k]:
                if obj in done:
                    continue
                done.add(obj)
                if (obj.x1 <= x0 or x1 <= obj.x0 or
                    obj.y1 <= y0 or y1 <= obj.y0):
                    continue
                ret.append(obj)

        return ret
    
def csort(objs, key):
    """Order-preserving sorting function."""
    idxs = dict((obj, i) for (i, obj) in enumerate(objs))
    return sorted(objs, key=lambda obj: (key(obj), idxs[obj]))
