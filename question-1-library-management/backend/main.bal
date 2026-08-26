import ballerina/http;

service /api on new http:Listener(8080) {

    resource function get assets() returns Asset[] {
        return assets.toArray();
    }

    resource function get assets/[string assetTag]() returns Asset|http:NotFound {
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

    resource function post assets(Asset asset) returns Asset|http:Conflict {
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