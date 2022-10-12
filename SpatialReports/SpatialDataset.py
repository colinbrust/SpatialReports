from dataclasses import dataclass, field
import datetime as dt
from pathlib import Path
from typing import Callable, List, Any, Dict
import json

@dataclass
class SpatialDataset:
    source: str | Path | Callable
    name: str
    time_start: dt.date | dt.datetime
    time_end: dt.date | dt.datetime
    summary: Dict[str, Dict[str, str]]
    source_args: None | List[Any]
    data: List[Path] = field(init=False)


    def __post_init__(self):
        if isinstance(self.source, Callable):
            self.data = self.source(*self.source_args)
        elif isinstance(self.source, (str, Path)):
            self.data = [x for x in Path(self.source).iterdir()]
        else:
            raise TypeError("The SpatialDataset source be a str, Path, or Callable object")
    
    def to_json(self, f_name: None | str | Path) -> Dict[str, Any] | Path:
        dat = {
            'name': self.name,
            'time_start': str(self.time_start),
            'time_end': str(self.time_end),
            'summary': self.summary,
            'data': [x.stem for x in self.data]
        }

        if f_name:
            with open(f_name) as f:
                json.dump(dat, f)
            return Path(f_name)
        return dat
