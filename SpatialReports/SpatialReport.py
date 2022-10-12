from dataclasses import dataclass
from pathlib import Path
import geopandas as gpd
from typing import List
from SpatialDataset import SpatialDataset

@dataclass
class SpatialReport:
    features: str | Path | gpd.GeoDataFrame
    datasets: List[SpatialDataset]
    write_dir: str | Path # Look into whether I can write/read files between R/python in memory with redis
    crs: str

    def __post_init__(self):
        pass
        # if features is a list of features, join them into a single feature. 
    def to_json(self):
        pass

