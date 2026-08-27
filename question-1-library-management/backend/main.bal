import ballerina/http;

service /api on new http:Listener(8080) {

    // ============================================================
    // ASSET MANAGEMENT
    // ============================================================

    // GET all assets
    resource function get assets() returns Asset[] {
        return assets.toArray();
    }

    // GET a single asset by assetTag
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

    // CREATE a new asset
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

    // UPDATE an existing asset
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

    // DELETE an asset
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


    // ============================================================
    // INSTITUTION AND SITE FILTERING
    // ============================================================

    // GET assets by institution
    resource function get assets/institution/[string institution]()
            returns Asset[] {

        Asset[] result = [];

        foreach Asset asset in assets {
            if asset.institution == institution {
                result.push(asset);
            }
        }

        return result;
    }

    // GET assets by institution AND site
    resource function get assets/institution/[string institution]/site/[string site]()
            returns Asset[] {

        Asset[] result = [];

        foreach Asset asset in assets {
            if asset.institution == institution && asset.site == site {
                result.push(asset);
            }
        }

        return result;
    }


    // ============================================================
    // COMPONENT MANAGEMENT
    // ============================================================

    // ADD a component to an asset
    resource function post assets/[string assetTag]/components(Component component)
            returns Asset|http:NotFound|http:Conflict {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        foreach Component existingComponent in asset.components {
            if existingComponent.compId == component.compId {
                return <http:Conflict>{
                    body: {
                        message: "Component with this compId already exists",
                        compId: component.compId,
                        assetTag: assetTag
                    }
                };
            }
        }

        asset.components.push(component);
        assets.put(asset);

        return asset;
    }

    // REMOVE a component from an asset
    resource function delete assets/[string assetTag]/components/[string compId]()
            returns Asset|http:NotFound {

        if !assets.hasKey(assetTag) {
            return <http:NotFound>{
                body: {
                    message: "Asset not found",
                    assetTag: assetTag
                }
            };
        }

        Asset asset = assets.get(assetTag);

        int componentIndex = -1;

        foreach int index in 0 ..< asset.components.length() {
            if asset.components[index].compId == compId {
                componentIndex = index;
                break;
            }
        }

        if componentIndex == -1 {
            return <http:NotFound>{
                body: {
                    message: "Component not found",
                    compId: compId,
                    assetTag: assetTag
                }
            };
        }

        // Ballerina's remove() returns the removed element.
        _ = asset.components.remove(componentIndex);

        assets.put(asset);

        return asset;
    }
}