<div class="modal fade" id="delete_account_modal">
                    <div class="modal-dialog modal-lg">
                        <div style="    background-color: rgb(24 24 24);
    -webkit-box-shadow: 5px 5px 15px 5px #fefefe;
    box-shadow: 3px 3px 13px 3px #fc2e2e;" class="modal-content">
                            <div style="border-bottom:1px solid rgb(220, 53, 69)" class="modal-header">
                                <h2 style="color: #ff3e3e" class="modal-title">Are you sure?</h2>
                            </div>
                            <div class="modal-body">
                                <p style="font-weight: 600;font-size: 1.3rem;color: #ff3e3e;">All the data related to you will be deleted permanently (files, comments, messages etc.), but you can always recover your account (NOT the data).</p>
                            </div>
                            <div style="border-top: 1px solid rgb(220, 53, 69);display: flex;justify-content: space-between;" class="modal-footer">
                                <button type="button" class="btn btn-primary no-standup" data-dismiss="modal">Cancel</button>
                                <button onclick="window.location.replace(
                                        'delete-account?email=' + encodeURIComponent('<c:out
                                        value="${email}"/>') + '&token=' + '${code}');" id="confirm_delete_account"
                                        type="button" class="btn btn-danger no-standup" data-dismiss="modal">Delete
                                    Account
                                </button>

                            </div>
                        </div>
                    </div>
                </div>