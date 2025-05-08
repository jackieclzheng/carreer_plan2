
package com.university.careerplanning.dto;

import java.util.List;

public class SearchResponse {
    private List<CareerDTO> careers;
    private long total;
    private int page;
    private int pageSize;
    
    // Getters and Setters
    public List<CareerDTO> getCareers() { return careers; }
    public void setCareers(List<CareerDTO> careers) { this.careers = careers; }
    
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    
    public int getPage() { return page; }
    public void setPage(int page) { this.page = page; }
    
    public int getPageSize() { return pageSize; }
    public void setPageSize(int pageSize) { this.pageSize = pageSize; }
}

