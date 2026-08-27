import ballerina/http;

service /api on new http:Listener(8080) {

    // GET /api/assets
    // Returns all assets
    resource function get assets() returns Asset[] {
        return assets.toArray();
    }

    // GET /api/assets/{assetTag}
    // Returns one asset by its unique assetTag
    resource function get assets/[string assetTag]()
            returns Asset|http:NotFound {

        if assets.hasKey(assetTag) {
            return assets.get(assetTag);
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    // GET /api/assets/institution/{institution}
    // Returns all assets belonging to a specific institution
    resource function get assets/institution/[string institution]()
            returns Asset[] {

        Asset[] filteredAssets = [];

        foreach Asset asset in assets {
            if asset.institution == institution {
                filteredAssets.push(asset);
            }
        }

        return filteredAssets;
    }

    // GET /api/assets/institution/{institution}/site/{site}
    // Returns assets belonging to a specific institution and site/campus
    resource function get assets/institution/[string institution]/site/[string site]()
            returns Asset[] {

        Asset[] filteredAssets = [];

        foreach Asset asset in assets {
            if asset.institution == institution && asset.site == site {
                filteredAssets.push(asset);
            }
        }

        return filteredAssets;
    }

    // POST /api/assets
    // Creates a new asset
    resource function post assets(Asset asset)
            returns Asset|http:Conflict {

        if assets.hasKey(asset.assetTag) {
            return <http:Conflict>{
                body: {
                    message: "Asset with this assetTag already exists",
                    assetTag: asset.assetTag
                }
            };
        }

        assets.add(asset);
        return asset;
    }

    // PUT /api/assets/{assetTag}
    // Updates an existing asset
    resource function put assets/[string assetTag](Asset updatedAsset)
            returns Asset|http:NotFound|http:BadRequest {

        if assetTag != updatedAsset.assetTag {
            return <http:BadRequest>{
                body: {
                    message: "Path assetTag does not match payload assetTag"
                }
            };
        }

        if assets.hasKey(assetTag) {
            assets.put(updatedAsset);
            return updatedAsset;
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }

    // DELETE /api/assets/{assetTag}
    // Deletes an asset
    resource function delete assets/[string assetTag]()
            returns http:NoContent|http:NotFound {

        if assets.hasKey(assetTag) {
            _ = assets.remove(assetTag);
            return <http:NoContent>{};
        }

        return <http:NotFound>{
            body: {
                message: "Asset not found",
                assetTag: assetTag
            }
        };
    }
}