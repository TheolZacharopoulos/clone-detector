module CloneDetection::Utils::ClonesGeneralize

import CloneDetection::ClonePairs;
import CloneDetection::Statements::TreeSimilarity;
import CloneDetection::Utils::ParentIndex;
import CloneDetection::Utils::ProgressTracker;
import Configurations;

import Map;
import Prelude;

ClonePairs generalizeClones(ClonePairs clones, bool (node, node) areParentsEqual) {
    
    // * 1. ClonesToGeneralize = Clones
    ClonePairs clonesToGeneralize = clones;
    
    startProgress("generalize-clones", size(clones));
    
    // * 2. While ClonesToGeneralize≠∅
    while (true) {
        
        if (size(clonesToGeneralize) == 0) break;
        
        advanceProgress("generalize-clones", 1);
        
        currentKey = toList(domain(clonesToGeneralize))[0];
        ClonePair pair = clonesToGeneralize[currentKey];
        
        // * 3. Remove clone(i,j) from ClonesToGeneralize
        clonesToGeneralize = delete(clonesToGeneralize, currentKey);
        
        if (!hasParent(pair.origin)) {
            continue;
        }
        
        // * 4. If CompareClones(ParentOf(i), ParentOf(j)) > SimilarityThreshold
        parentOfOrigin = getParentOf(pair.origin);
        parentOfClone = getParentOf(pair.clone);
        
        if (parentOfOrigin@uniqueKey != parentOfClone@uniqueKey && areParentsEqual(parentOfOrigin, parentOfClone)) {
        
            // * 5. RemoveClonePair(Clones,i,j)
            clones = removeCloneFromClonePairs(pair.origin, clones);
            clones = removeCloneFromClonePairs(pair.clone, clones);
            
            // * 6. AddClonePair(Clones, ParentOf(i), ParentOf(j))
            clones = addClonePair(parentOfOrigin, parentOfClone, clones); 
            
            // * 7. AddClonePair(ClonesToGeneralize, ParentOf(i),ParentOf(j))
            clonesToGeneralize = addClonePair(parentOfOrigin, parentOfClone, clonesToGeneralize);
            increaseProgressTotal("generalize-clones", 1);
        }
    }
    
    endProgress("generalize-clones");

    return clones;
}